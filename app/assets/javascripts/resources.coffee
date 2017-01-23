jQuery ->
  $('#resource_admin_user_input').change ->
    $('#resource_bill_rate').val('')
    $('#resource_cost_rate').val('')
    admin_user_id = $('#resource_admin_user_input :selected').val()
    if admin_user_id != ''
      escaped_admin_user_id = admin_user_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
      url = '/admin/api/admin_user_details?admin_user_id=' + escaped_admin_user_id
      $.ajax url,
        success: (data, status, xhr) ->
          $('#resource_bill_rate').val(data['admin_user_details'].bill_rate)
          $('#resource_cost_rate').val(data['admin_user_details'].cost_rate)
        error: (xhr, status, err) ->
          console.log(err)