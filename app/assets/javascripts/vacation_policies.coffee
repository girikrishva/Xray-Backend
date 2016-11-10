jQuery ->
  $('#vacation_policy_vacation_code_input').change ->
    vacation_code_id = $('#vacation_policy_vacation_code_input :selected').val()
    escaped_vacation_code_id = vacation_code_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    url = '/admin/api/vacation_policy_description?lookup_id=' + escaped_vacation_code_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#vacation_policy_description').val(data.description)
      error: (xhr, status, err) ->
        console.log(err)