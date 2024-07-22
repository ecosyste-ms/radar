require 'pagy/extras/headers'
require 'pagy/extras/limit'
require 'pagy/extras/countless'
require 'pagy/extras/bootstrap'

Pagy::DEFAULT[:limit] = 25
Pagy::DEFAULT[:limit_param] = :per_page
Pagy::DEFAULT[:limit_max] = 100
