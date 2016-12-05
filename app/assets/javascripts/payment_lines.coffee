jQuery ->
  $('#payment_line_invoice_line_input').change ->
    invoice_line_id = $('#payment_line_invoice_line_input :selected').val()
    escaped_invoice_line_id = invoice_line_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    url = '/admin/api/invoice_line_name?invoice_line_id=' + escaped_invoice_line_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#payment_line_narrative').val(data.invoice_line_name)
        console.log result[0].name
      error: (xhr, status, err) ->
        console.log(err)
    url = '/admin/api/unapplied_amount?invoice_line_id=' + escaped_invoice_line_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#payment_line_line_amount').val(data.unapplied_amount)
        console.log result[0].name
      error: (xhr, status, err) ->
        console.log(err)