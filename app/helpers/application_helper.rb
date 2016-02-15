module ApplicationHelper
  def remote_resource(url)
    if 'development' == Rails.env
      local_name = url.split('/')[-1]
      File.join('cached', local_name)
    else
      url
    end
  end
end
