jQuery ->
  $('#payment_line_invoice_header_input').change ->
    if $('#payment_line_invoice_header_input :selected').val() == ""
      $('#payment_line_invoice_line_id').attr('disabled', true)
    else
      $('#payment_line_invoice_line_id').attr('disabled', false)
      invoice_header_id = $('#payment_line_invoice_header_input :selected').val()
      escaped_invoice_header_id = invoice_header_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
      url = '/admin/api/invoice_lines_for_header?invoice_header_id=' + escaped_invoice_header_id
      $.ajax url,
        success: (data, status, xhr) ->
          $('#payment_line_invoice_line_id').empty()
          $('#payment_line_invoice_line_id').append('<option value=""></option>')
          result = data.invoice_lines
          i = 0
          while i < result.length
            option_line = ('<option value="' + result[i].id + '">' + 'Id: [' + result[i].id + '], Narrative: [' + result[i].narrative + '], Amount: [' + result[i].line_amount + '], Unpaid: [')
            url = '/admin/api/unpaid_amount?invoice_line_id=' + result[i].id
            i++
            $.ajax url,
              success: (data, status, xhr) ->
                option_line += data.unpaid_amount + ']</option?'
                $('#payment_line_invoice_line_id').append(option_line)
              error: (xhr, status, err) ->
                console.log(err)
          console.log result[0].name
        error: (xhr, status, err) ->
          console.log(err)
  $('#payment_line_invoice_line_input').change ->
    invoice_line_id = $('#payment_line_invoice_line_input :selected').val()
    escaped_invoice_line_id = invoice_line_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    url = '/admin/api/invoice_line_name?invoice_line_id=' + escaped_invoice_line_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#payment_line_narrative').val(data.invoice_line_name)
      error: (xhr, status, err) ->
        console.log(err)
    url = '/admin/api/unpaid_amount?invoice_line_id=' + escaped_invoice_line_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#payment_line_line_amount').val(data.unpaid_amount)
      error: (xhr, status, err) ->
        console.log(err)