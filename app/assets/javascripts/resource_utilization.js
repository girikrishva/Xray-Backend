  $(".col-business_unit_id").hide()
	$(".col-id").hide()
  $.urlParam = function(name){
    var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
    if (results==null){
       return null;
    }
    else{
       return results[1] || 0;
    }
}
$(document).ready(function() {
    if ($.urlParam('q%5Bas_on_gteq_date%5D') != null)
{
       $('#q_as_on_gteq_date').val($.urlParam('q%5Bas_on_gteq_date%5D'));

}
    if ($.urlParam('q%5Bas_on_lteq_date%5D') != null)
{
       $('#q_as_on_lteq_date').val($.urlParam('q%5Bas_on_lteq_date%5D'));

}
  })
  $(".assigned_percent,.clocked_percent,.utilization_percent").on('click',function(){
    var id = $(this).attr('id').split("_")[1]
    var from = $('#q_as_on_gteq_date').val()
    var to = $('#q_as_on_lteq_date').val()
		responce  = ajax_call("api/resource_efficiency?admin_user_id="+id+"&from_date="+from+"&to_date="+to+"&with_details=true")
		var html_value = "<span id='close' style='cursor:pointer' hidden></span>"
    html_value += convert_ajax_to_htm(responce["data"])        
		$(".ajax_content").html(html_value)
		$(".created_at,.updated_at,.deleted_at,.comments,.data,.staffing_required_details").hide()
})

    $(".deployable_resources").on('click',function(){
    var id = $(this).attr('id')
    var from = $('#q_as_on_gteq_date').val()
    var to = $('#q_as_on_lteq_date').val()
    responce  = ajax_call("api/business_unit_efficiency?business_unit_id="+id+"&from_date="+from+"&to_date="+to+"&with_details=true")
    var html_value = "<span id='close' style='cursor:pointer' hidden></span>"
    html_value += convert_ajax_to_htm(responce["data"])
    $.each( responce["data"]["resource_efficiency_details"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value)
                }
            });
            html_value += "</table>"
            
    $(".ajax_content").html(html_value)
    $(".created_at,.updated_at,.deleted_at,.comments,.data,.resource_efficiency_details").hide()
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
