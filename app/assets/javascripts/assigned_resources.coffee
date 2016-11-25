jQuery ->
  $('#assigned_resource_staffing_requirement_input').change ->
    staffing_requirement_id = $('#assigned_resource_staffing_requirement_input :selected').val()
    escaped_staffing_requirement_id = staffing_requirement_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    url = '/admin/api/skill_for_staffing?staffing_requirement_id=' + escaped_staffing_requirement_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#assigned_resource_skill_id').val(data.skill_id)
      error: (xhr, status, err) ->
        console.log(err)
    url = '/admin/api/designation_for_staffing?staffing_requirement_id=' + escaped_staffing_requirement_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#assigned_resource_designation_id').val(data.designation_id)
      error: (xhr, status, err) ->
        console.log(err)
    url = '/admin/api/hours_per_day_for_staffing?staffing_requirement_id=' + escaped_staffing_requirement_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#assigned_resource_hours_per_day').val(data.hours_per_day)
      error: (xhr, status, err) ->
        console.log(err)
    url = '/admin/api/start_date_for_staffing?staffing_requirement_id=' + escaped_staffing_requirement_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#assigned_resource_start_date').val(data.start_date)
      error: (xhr, status, err) ->
        console.log(err)
    url = '/admin/api/end_date_for_staffing?staffing_requirement_id=' + escaped_staffing_requirement_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#assigned_resource_end_date').val(data.end_date)
      error: (xhr, status, err) ->
        console.log(err)
    if staffing_requirement_id == ""
      $('#assigned_resource_resource_id').attr('disabled', true)
    else
      $('#assigned_resource_resource_id').attr('disabled', false)
      url = '/admin/api/resources_for_staffing?staff_requirement_id=' + escaped_staffing_requirement_id
      $.ajax url,
        success: (data, status, xhr) ->
          $('#assigned_resource_resource_id').empty
        error: (xhr, status, err) ->
          $('#assigned_resource_resource_id').empty
          console.log(err)