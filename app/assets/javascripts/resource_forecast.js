	$(".staffing_required,.deployable_resources,.staffing_fulfilled").on('click',function(){
		var as_on = "2016-11-25"
		responce  = ajax_call("api/staffing_forecast?as_on="+as_on+"&with_details=true")
		var html_value = "<span id='close' style='cursor:pointer' hidden></span>"
		$.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value)
                }
            });
            html_value += "</table>"
              $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["staffing_required_details"][0]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["staffing_required_details"][0])
                }
            });
              html_value += "</table>"
                $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["staffing_fulfilled_details"][0]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["staffing_fulfilled_details"][0])
                }
                });
                html_value += "</table>"
                    $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["deployable_resources_details"][0]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["deployable_resources_details"][0])
                }
                });
                html_value += "</table>"
            
		$(".ajax_content").html(html_value)
		$(".created_at,.updated_at,.deleted_at,.comments,.data,.staffing_required_details,.staffing_fulfilled_details,.deployable_resources_details,.id,.admin_user_id").hide()

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