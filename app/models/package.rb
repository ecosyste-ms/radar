class Package < ApplicationRecord
  belongs_to :registry
  has_many :versions
  has_many :dependent_repositories
  has_many :dependent_packages

  def self.list_owner_repo_names(owner)
    Octokit.auto_paginate = true
    Octokit.repositories(owner).map {|r| r[:full_name] }
  end

  def self.discover_from_owner(owner)
    list_owner_repo_names(owner).each do |full_name|
      puts "Discovering #{full_name} packages"
      discover_from_repository(full_name)
    end
  end

  def owner
    repository_url.split('/')[3]
  end

  def self.discover_from_repository(full_name)
    url = "https://packages.ecosyste.ms/api/v1/packages/lookup?repository_url=https://github.com/#{full_name}"
    response = Faraday.get(url)

    return unless response.success?

    packages = JSON.parse(response.body)

    packages.each do |package|
      puts "Syncing #{package['ecosystem']}/#{package['name']}"
      registry = Registry.find_by(ecosystem: package['ecosystem'])
      pkg = registry.packages.find_or_create_by(name: package['name'], ecosystem: package['ecosystem'])
      pkg.sync
    end
  end

  def sync
    # TODO load details from packages.ecosyste.ms
    url = "https://packages.ecosyste.ms/api/v1/registries/#{registry.name}/packages/#{name}"
    response = Faraday.get(url)

    return unless response.success?

    package = JSON.parse(response.body)

    self.description = package['description']
    self.repository_url = package['repository_url']
    self.homepage = package['homepage']
    self.licenses = package['licenses']
    self.normalized_licenses = package['normalized_licenses']
    self.versions_count = package['versions_count']
    self.latest_release_published_at = package['latest_release_published_at']
    self.latest_release_number = package['latest_release_number']
    self.keywords_array = package['keywords_array']
    self.language = package['language']
    self.status = package['status']
    self.last_synced_at = Time.now
    self.save

    sync_versions
    sync_advisories
  end

  def sync_advisories
    url = "https://advisories.ecosyste.ms/api/v1/advisories?ecosystem=#{ecosystem}&package_name=#{name}"
    response = Faraday.get(url)
    return unless response.success?
    advisories = JSON.parse(response.body)

    # TODO filter packages to only this one
    advisories.each do |advisory|
      advisory['packages'].select! {|p| p['package_name'] == name }
    end

    self.advisories = advisories
    self.save
  end

  def dependent_repos_count_by_version
    dependent_repositories
      .group(:resolved_versions).count
      .reject {|k, v| k.compact.empty? }
      .sort_by {|k, v| v }.reverse
  end

  def self.dependent_repos_count_by_major_version(scope)
    scope
      .group('UNNEST(resolved_major_versions)').count
      .reject {|k, v| k.empty? }
      .sort_by {|k, v| v }.reverse
  end

  def self.dependent_repos_count_by_minor_version(scope)
    scope
      .group('UNNEST(resolved_minor_versions)').count
      .reject {|k, v| k.empty? }
      .sort_by {|k, v| v }.reverse
  end

  def self.dependent_repos_count_by_patch_version(scope)
    scope
      .group('UNNEST(resolved_patch_versions)').count
      .reject {|k, v| k.empty? }
      .sort_by {|k, v| v }.reverse
  end

  def version_numbers
    @version_numbers ||= versions.pluck(:number)
  end

  def resolved_version(range)
    v = version_numbers.map {|v| SemanticRange.clean(v, loose: true) }.compact
    number = SemanticRange.max_satisfying(v, range, platform: ecosystem.humanize, loose: true)
  end

  def affected_versions(range)
    v = version_numbers.map {|v| SemanticRange.clean(v, loose: true) }.compact
    v.select {|v| SemanticRange.satisfies?(v, range, platform: ecosystem.humanize, loose: true) }
  end

  def sync_versions
    # TODO pagination
    url = "https://packages.ecosyste.ms/api/v1/registries/#{registry.name}/packages/#{name}/versions?per_page=1000"
    response = Faraday.get(url)
    return unless response.success?
    versions = JSON.parse(response.body)

    versions.each do |version|
      v = self.versions.find_or_create_by(number: version['number'])
      v.published_at = version['published_at']
      v.save
    end
    update(versions_count: versions.count)
  end

  def sync_dependent_repositories
    page = 1
    dependencies = []
  
    loop do
      url = "https://repos.ecosyste.ms/api/v1/usage/#{ecosystem}/#{name}/dependencies?per_page=100&page=#{page}&after=#{last_dependency_id}"

      response = Faraday.get(url)
      break unless response.success?
      dependencies = JSON.parse(response.body)

      break if dependencies.count == 0

      groups = dependencies.group_by{|dep| dep['repository']['full_name']  }

      existing_repos = dependent_repositories.where(full_name: groups.keys)

      groups.each do |full_name, deps|
        repo = existing_repos.find{|r| r.full_name == full_name}
        if repo.nil?
          repo = dependent_repositories.find_or_create_by(full_name: full_name)
        end
        
        repo.repository_fields = deps.first['repository']
        
        repo.manifests ||= {}

        deps.each do |dep|
          repo.manifests[dep['manifest']['filepath']] ||= []
          repo.manifests[dep['manifest']['filepath']] << dep.except('repository', 'manifest', 'package_name', 'ecosystem')
          repo.manifests[dep['manifest']['filepath']].uniq!
        end
        repo.set_details
        repo.save if repo.changed?
      end
      page += 1
      break if dependencies.count < 1000
    end

    update(last_dependency_id: dependencies.last['id'], dependent_repositories_count: dependent_repositories.count) if dependencies.present?
  end

  def find_dependent_github_repo_names
    return [] unless repository_url.present? && repository_url.match(/github\.com/i)
    dependents_url = "#{repository_url}/network/dependents?dependent_type=REPOSITORY"

    page_contents = fetch_html(dependents_url)
    # TODO handle errors loading html
    if page_contents.css('.select-menu-item').length > 0
      # multiple packages in a single repo
      dependents_urls = page_contents.css('.select-menu-item').map{|s| s.attr('href')}.map{|path| "https://github.com#{path}"}
    else
      dependents_urls = [dependents_url]
    end

    new_dependent_repos = []

    dependents_urls.each do |dependents_url|
      while dependents_url.present? do
        begin
          page_contents = fetch_html(dependents_url)
          names = page_contents.css('#dependents .Box-row .f5').map{|node| node.text.squish.gsub(' ', '') }
          new_dependent_repos += names
          dependents_url = page_contents.css('.paginate-container .btn.btn-outline.BtnGroup-item').select{|n| n.text == 'Next'}.first.try(:attr, 'href')
          sleep 5
        rescue Faraday::ConnectionFailed
          dependents_url = nil
        end
      end
    end

    new_dependent_repos.uniq
  end

  def enqueue_dependent_github_repo_syncs
    find_dependent_github_repo_names.each do |repo_name|
      url = "https://repos.ecosyste.ms/api/v1/repositories/lookup?url=https://github.com/#{repo_name}"
      response = Faraday.get(url)
    end
  end

  def fetch_html(url)
    response = Faraday.get(url)
    Nokogiri::HTML(response.body)
  end

  def sync_dependent_packages
    page = 1
    dependencies = []
  
    loop do
      url = "https://packages.ecosyste.ms/api/v1/dependencies?ecosystem=#{ecosystem}&package_name=#{name}&per_page=100&page=#{page}&after=#{last_package_dependency_id}"

      response = Faraday.get(url)
      
      break unless response.success?
      dependencies = JSON.parse(response.body)

      break if dependencies.count == 0

      groups = dependencies.group_by{|dep| dep['package']['name']  }

      existing_packages = dependent_packages.where(name: groups.keys)

      groups.each do |name, deps|
        package = existing_packages.find{|r| r.name == name}
        if package.nil?
          package = dependent_packages.find_or_create_by(name: name)
        end
        
        package.package_fields = deps.first['package']
        
        package.versions ||= {}

        deps.each do |dep|
          package.versions[dep['version']['number']] ||= []
          package.versions[dep['version']['number']] << dep.except('package', 'package_name', 'ecosystem', 'version')
          package.versions[dep['version']['number']].uniq!
        end
        package.set_details
        package.save if package.changed?
      end
      page += 1
      break if dependencies.count < 100
    end

    update(last_package_dependency_id: dependencies.last['id'], dependent_packages_count: dependent_packages.count) if dependencies.present?
  end
end
