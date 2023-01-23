require 'pagy/extras/headers'
require 'pagy/extras/items'
require 'pagy/extras/countless'
require 'pagy/extras/bootstrap'

Pagy::DEFAULT[:items] = 25
Pagy::DEFAULT[:items_param] = :per_page
Pagy::DEFAULT[:max_items] = 100
