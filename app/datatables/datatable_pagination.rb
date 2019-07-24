module DatatablePagination
  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    possible_sort_columns[get_sort_params.to_i]
  end

  def sort_direction
    if params['order'].blank?
      'desc'
    else
      params['order']['0']['dir'] == 'desc' ? 'desc' : 'asc'
    end

  end

  def get_sort_params
    if params['order'].blank?
      'id'
    else
      column_number = params['order']['0']['column']
      params['columns'][column_number]['data']
    end

  end

end