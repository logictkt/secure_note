class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern Chrome (120+). All other browsers are blocked.
  allow_browser versions: { chrome: 120, safari: false, firefox: false, opera: false, ie: false }

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :set_variants

  private

  def set_variants
    variants = []
    variants << :admin   if params[:admin]   == "true"
    variants << :console if params[:console] == "true"
    request.variant = variants
  end
end
