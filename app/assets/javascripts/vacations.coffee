jQuery ->
  $('#vacation_vacation_code_input').change ->
    $('#vacation_narrative').val($('#vacation_vacation_code_input :selected').text())
  $('#vacation_start_date').change ->
    $('#vacation_end_date').val($('#vacation_start_date').val())