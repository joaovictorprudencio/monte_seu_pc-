module ComponentsHelper
  def format_storage(value)
    if value >= 1000
      "#{value/1000.0} TB "
    else
      "#{value} GB"
    end
  end
end
