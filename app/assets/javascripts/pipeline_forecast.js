$(document).ready(function() {
	$(".col-expected_start,.col-pipeline_status_id,.hidden").hide()
	$(".text_link").on('click',function(){
		var status_id = $(this).closest('tr').find('td:eq(-1)').text()
		var as_on = $(this).find(".hidden").html() + "-01"
		responce  = ajax_call("api/pipeline_for_status?status_id="+status_id+"&as_on="+as_on+"&with_details=true")
		var html_value = "<span id='close' style='cursor:pointer' hidden></span>"+convert_ajax_to_htm(responce)
		$.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["pipeline"]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["pipeline"])
                }
            });
            html_value += "</table>"
		$(".ajax_content").html(html_value)
		$(".created_at,.updated_at,.deleted_at,.comments,.data").hide()
	})

	      function return_only_t_data(responce){
             var ajax_content_value = "</tr><tr>"
             $.each(responce, function(key, value) {
                  ajax_content_value +="<td class='"+key.replace(" ", "_")+"'style = 'border: 1px solid black;' >"+value+"</td>" 
                  });
           ajax_content_value +="</tr>"
           return ajax_content_value
          }

          function convert_ajax_to_htm(responce){
   var ajax_content_value = "<table><tr>"
           $.each(responce, function(key, value) {
                  ajax_content_value +="<th class='"+key.replace(" ", "_")+" 'style = 'border: 1px solid black;'>"+key.replace(/_/g," ").toUpperCase()+"</th>" 
                  });
           ajax_content_value += "</tr><tr>"
             $.each(responce, function(key, value) {
                  ajax_content_value +="<td class='"+key.replace(" ", "_")+"'style = 'border: 1px solid black;' >"+value+"</td>" 
                  });
           ajax_content_value +="</tr></table>"
           return ajax_content_value
          }

	function ajax_call(url) {
	    var responce = ""
	 $.ajax({
	        async: false,
	        url: url,
	          dataType: 'json',
	        success: function (data) {
	           responce =  data;
	        }
	    })
	 return responce;
	}

	  $(function() {
    $('[data-popup-open]').on('click', function(e)  {
        var targeted_popup_class = jQuery(this).attr('data-popup-open');
        $('[data-popup="' + targeted_popup_class + '"]').fadeIn(350);
        $(".dropdown_menu").toggle()
        e.preventDefault();
    });
 
    $('[data-popup-close]').on('click', function(e)  {
        var targeted_popup_class = jQuery(this).attr('data-popup-close');
        $('[data-popup="' + targeted_popup_class + '"]').fadeOut(10);
        $(".dropdown_menu").toggle()
        e.preventDefault();
    });
});
})