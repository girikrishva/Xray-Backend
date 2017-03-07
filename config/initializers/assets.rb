# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'
Rails.application.config.assets.precompile += %w( pop_up.js )
Rails.application.config.assets.precompile += %w( pop_up.css )
Rails.application.config.assets.precompile += %w( delivery_health.js )
Rails.application.config.assets.precompile += %w( pipeline_forecast.js )
Rails.application.config.assets.precompile += %w( resource_forecast.js )
Rails.application.config.assets.precompile += %w( resource_utilization.js )
Rails.application.config.assets.precompile += %w( html_to_canvas.js )
Rails.application.config.assets.precompile += %w( sorting.js )
Rails.application.config.assets.precompile += %w( charts.js )
# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
