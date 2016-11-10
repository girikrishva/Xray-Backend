jQuery ->
  $('#project_type_project_type_code_input').change ->
    project_type_code_id = $('#project_type_project_type_code_input :selected').val()
    escaped_project_type_code_id = project_type_code_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    url = '/admin/api/project_type_description?lookup_id=' + escaped_project_type_code_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#project_type_description').val(data.description)
      error: (xhr, status, err) ->
        console.log(err)