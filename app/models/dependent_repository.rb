class DependentRepository < ApplicationRecord

  belongs_to :package

  scope :owner, ->(owner) { where("repository_fields->>'owner' = ?", owner) }

  def description
    repository_fields['description']
  end

  def owner
    repository_fields['owner']
  end

  def short_name
    full_name.split('/').last
  end

  def calculate_resolved_versions
    requirements_by_path.map do |requirements|
      [package.resolved_version(requirements.join(' '))]
    end.flatten.compact.uniq
  end

  def calculate_resolved_major_versions
    calculate_resolved_versions.map do |v|
      v.split('.')[0] if v
    end.compact.uniq
  end

  def calculate_resolved_minor_versions
    calculate_resolved_versions.map do |v|
      v.split('.')[0..1].join('.') if v
    end.compact.uniq
  end

  def calculate_resolved_patch_versions
    calculate_resolved_versions.map do |v|
      v.split('.')[0..2].join('.') if v
    end.compact.uniq
  end

  def paths
    manifests.map{|filepath, deps| File.dirname(filepath)}
  end

  def manifests_by_path
    manifests.group_by{|filepath, deps| File.dirname(filepath)}
  end

  def requirements_by_path
    manifests_by_path.map do |path, deps|
      deps.map do |filepath, deps|
        deps.map do |dep|
          dep['requirements']
        end
      end.flatten.compact.uniq
    end.uniq
  end

  def requirements
    manifests.map do |filepath, deps|
      deps.map do |dep|
        dep['requirements']
      end
    end.flatten.compact.uniq
  end

  def calculate_direct_dependency
    manifests.any? do |filepath, deps|
      deps.any?{|d| d['direct'] == true }
    end
  end
  
  def set_details
    self.resolved_versions = calculate_resolved_versions
    self.resolved_major_versions = calculate_resolved_major_versions
    self.resolved_minor_versions = calculate_resolved_minor_versions
    self.resolved_patch_versions = calculate_resolved_patch_versions
    self.direct_dependency = calculate_direct_dependency
  end

  def update_details
    self.set_details
    self.save if self.changed?
  end
end
