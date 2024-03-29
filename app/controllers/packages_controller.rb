class PackagesController < ApplicationController
  def index
    @scope = Package.all.order('dependent_repositories_count desc')
    @pagy, @packages = pagy(@scope)
  end

  def show
    @package = Package.find(params[:id])

    @scope = @package.dependent_repositories
    @scope = @scope.where(direct_dependency: params[:direct_dependency]) if params[:direct_dependency]
    @scope = @scope.where("(repository_fields->>'fork') = ?", params[:fork]) if params[:fork]
    @scope = @scope.where("(repository_fields->>'archived') = ?", params[:archived]) if params[:archived]
    @scope = @scope.select('UNNEST(resolved_versions) as resolved_versions').where(resolved_versions: Array(params[:resolved_versions])) if params[:resolved_versions]
    @scope = @scope.where(resolved_major_versions: Array(params[:resolved_major_versions])) if params[:resolved_major_versions]
    @scope = @scope.where(resolved_minor_versions: Array(params[:resolved_minor_versions])) if params[:resolved_minor_versions]
    @scope = @scope.where('resolved_patch_versions && ?', "{#{Array(params[:resolved_patch_versions]).join(',')}}") if params[:resolved_patch_versions]

    
    @owners = @scope.group_by(&:owner).map{|k,v| [k, v.size]}.sort_by{|k,v| -v}

    @scope = @scope.owner(params[:owner]) if params[:owner]

    @pagy, @dependent_repositories = pagy(@scope.order(Arel.sql("(repository_fields->>'stargazers_count')::text::integer").desc.nulls_last))


  end

  def dependent_packages
    @package = Package.find(params[:id])

    @scope = @package.dependent_packages
    @scope = @scope.where("(package_fields->>'status') = ?", params[:status]) if params[:status]
    @scope = @scope.select('UNNEST(resolved_versions) as resolved_versions').where(resolved_versions: Array(params[:resolved_versions])) if params[:resolved_versions]
    @scope = @scope.where(resolved_major_versions: Array(params[:resolved_major_versions])) if params[:resolved_major_versions]
    @scope = @scope.where(resolved_minor_versions: Array(params[:resolved_minor_versions])) if params[:resolved_minor_versions]
    @scope = @scope.where('resolved_patch_versions && ?', "{#{Array(params[:resolved_patch_versions]).join(',')}}") if params[:resolved_patch_versions]


    @pagy, @dependent_packages = pagy(@scope.order(Arel.sql("(package_fields->>'downloads')::text::integer").desc.nulls_last))
  end
end
