class DependentPackage < ApplicationRecord
  belongs_to :package

  def description
    package_fields['description']
  end

  def calculate_resolved_versions
    requirements.map do |reqs|
      [package.resolved_version(reqs)]
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
    versions.map{|filepath, deps| File.dirname(filepath)}
  end

  def versions_by_path
    versions.group_by{|filepath, deps| File.dirname(filepath)}
  end

  def requirements
    versions.map do |numbers, deps|
      deps.map do |dep|
        dep['requirements']
      end
    end.flatten.compact.uniq
  end
  
  def set_details
    self.resolved_versions = calculate_resolved_versions
    self.resolved_major_versions = calculate_resolved_major_versions
    self.resolved_minor_versions = calculate_resolved_minor_versions
    self.resolved_patch_versions = calculate_resolved_patch_versions
  end

  def update_details
    self.set_details
    self.save if self.changed?
  end
end
