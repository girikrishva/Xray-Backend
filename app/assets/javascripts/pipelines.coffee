jQuery ->
  $('#pipeline_business_unit_input').change ->
    business_unit_id = $('#pipeline_business_unit_input :selected').val()
    if business_unit_id != ''
      $('#pipeline_client_id').attr('disabled', false)
      escaped_business_unit_id = business_unit_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
      url = '/admin/api/clients_for_business_unit?business_unit_id=' + escaped_business_unit_id
      $.ajax url,
        success: (data, status, xhr) ->
          $('#pipeline_client_id').empty()
          $('#pipeline_client_id').append('<option value=""></option>')
          result = JSON.parse data.resources
          i = 0
          while i < result.length
            $('#pipeline_client_id').append('<option value="' + result[i].id + '">' + result[i].name + '</option>')
            i++
          console.log result[0].name
        error: (xhr, status, err) ->
          console.log(err)