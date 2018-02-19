class FilterPresenter

  attr_accessor :filters, :default, :current

  def initialize(filters, default)
    @filters = filters
    @default = default
    @current = default

    # prepend default if not in list
    unless @filters.include? @default
      @filters = [@default] + @filters
    end
  end

  def active
    if @filters.include? @current
      @current
    else
      @default
    end
  end

end
