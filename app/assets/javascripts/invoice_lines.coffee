jQuery ->
  $('#invoice_line_project_input').change ->
    $('#invoice_line_invoicing_milestone_id').attr('disabled', false)
    $('#invoice_line_invoice_adder_type_id').attr('disabled', false)
    project_id = $('#invoice_line_project_input :selected').val()
    escaped_project_id = project_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
    url = '/admin/api/invoicing_milestones_for_project?project_id=' + escaped_project_id
    $.ajax url,
      success: (data, status, xhr) ->
        $('#invoice_line_invoicing_milestone_id').empty()
        $('#invoice_line_invoicing_milestone_id').append('<option value=""></option>')
        result = JSON.parse data.invoicing_milestones
        i = 0
        while i < result.length
          option_line = '<option value="' + result[i].id + '">' + 'Id: [' + result[i].id + '], Name: [' + result[i].name + '],  Due on: [' + result[i].due_date + '], Amount: [' + result[i].amount + '], Uninvoiced: [' + data.uninvoiced[i] + ']</option>'
          $('#invoice_line_invoicing_milestone_id').append(option_line)
          i++
      error: (xhr, status, err) ->
        console.log(err)
  $('#invoice_line_invoicing_milestone_input').change ->
    $('#invoice_line_narrative').val("")
    $('#invoice_line_line_amount').val("")
    if $('#invoice_line_invoicing_milestone_id').val() == ""
      $('#invoice_line_invoice_adder_type_id').attr('disabled', false)
    else
      $('#invoice_line_invoice_adder_type_id').attr('disabled', true)
      invoicing_milestone_id = $('#invoice_line_invoicing_milestone_input :selected').val()
      escaped_invoicing_milestone_id = invoicing_milestone_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
      url = '/admin/api/invoicing_milestone?invoicing_milestone_id=' + escaped_invoicing_milestone_id
      $.ajax url,
        success: (data, status, xhr) ->
          $('#invoice_line_invoicing_milestone_input').val(escaped_invoicing_milestone_id)
          $('#invoice_line_narrative').val(data.invoicing_milestone.name)
          url = '/admin/api/invoicing_milestone_uninvoiced?invoicing_milestone_id=' + escaped_invoicing_milestone_id
          $.ajax url,
            success: (data, status, xhr) ->
              $('#invoice_line_line_amount').val(data.invoicing_milestone_uninvoiced)
            error: (xhr, status, err) ->
              console.log(err)
        error: (xhr, status, err) ->
          console.log(err)
  $('#invoice_line_invoice_adder_type_input').change ->
    $('#invoice_line_narrative').val("")
    $('#invoice_line_line_amount').val("")
    if $('#invoice_line_invoice_adder_type_id').val() == ""
      $('#invoice_line_invoicing_milestone_id').attr('disabled', false)
    else
      $('#invoice_line_invoicing_milestone_id').attr('disabled', true)
      invoice_adder_type_id = $('#invoice_line_invoice_adder_type_input :selected').val()
      escaped_invoice_adder_type_id = invoice_adder_type_id.replace(/([ #;&,.+*~\':"!^$[\]()=>|\/@])/g, '\\$1')
      url = '/admin/api/invoice_adder_type?invoice_adder_type_id=' + escaped_invoice_adder_type_id
      $.ajax url,
        success: (data, status, xhr) ->
          $('#invoice_line_invoice_adder_type_input').val(escaped_invoice_adder_type_id)
          $('#invoice_line_narrative').val(data.invoice_adder_type.name)
        error: (xhr, status, err) ->
          console.log(err)