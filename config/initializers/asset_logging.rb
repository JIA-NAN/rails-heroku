# more info on asset compile
# http://stackoverflow.com/questions/19325039/how-to-debug-a-rails-asset-precompile-which-is-unbearably-slow
Rails.application.assets.logger = Logger.new($stdout)
