module ComponentsHelper
  def format_storage(value)
    if value >= 1000
      "#{value/1000.0} TB "
    else
      "#{value} GB"
    end
  end

  def add_atr(component:)
    cp =  Component.update(storage: 8)
  end
end
