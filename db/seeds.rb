Registry.sync_all
r = Registry.find_by_ecosystem('rubygems')
p = r.packages.find_or_create_by(name: 'split', ecosystem: 'rubygems')
p.sync
p.sync_dependent_repositories