$(document).ready(function() {
  $("#page_title").html("Pipeline Forecast")
 $( "#datepicker" ).datepicker({ dateFormat: 'yy-mm-dd' });
	$("#index_table_pipeline_forecasts,.pagination_information,.pagination,.breadcrumb").hide()
   var fullDate = new Date()
   // on change start
         $("#datepicker").on('change',function(){
        currentDate = $(this).val()
        responce  = ajax_call("api/pipeline_for_all_statuses?as_on="+currentDate)
    var html_value = ""
 $("#initial_table").html(table_view(responce,html_value))
  $(".period").text($(".table tbody tr th:nth-child(2)").html()+" to "+$(".table tbody tr th:last").html())
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
  
      })
      $("#datepicker").val(currentDate)

   // on change end
  var twoDigitMonth = ((fullDate.getMonth().length+1) === 1)? (fullDate.getMonth()+1) : '0' + (fullDate.getMonth()+1);
  var currentDate = fullDate.getDate() + "/" + twoDigitMonth + "/" + fullDate.getFullYear();
  responce  = ajax_call("api/pipeline_for_all_statuses?as_on="+currentDate)
  html_value = ""
  $("#datepicker").val(currentDate)
  $("#initial_table").html(table_view(responce,html_value))
  $(".period").text($(".table tbody tr th:nth-child(2)").html()+" to "+$(".table tbody tr th:last").html())
  $(".text_link").on('click',function(){
  status_id = $("."+$(this).parent().find(".pipeline_status").html()).attr('id')
  as_on = $(this).attr('class').split(" ")[0]
    responce  = ajax_call("api/pipeline_for_status?status_id="+status_id+"&as_on="+as_on+"&with_details=true")
    var html_value = "<span id='close' style='cursor:pointer' hidden></span>"
    
    $(".modal-header").append("<span class= 'hiddding_header'style='font-family: fantasy;font-size: 20px;align-self: center;margin-top: 900px;margin-left: 460px;'>Status:"+$(this).parent().find(".pipeline_status").html()+" As On "+as_on+"</span>")
    $(".hiddding_header").hide()
    $(".hiddding_header").first().show()
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
     $.each($("td.expected_value,td.total_pipeline"), function( index1, value1 ){
     $(this).text("$"+$(this).text())
      })
		$(".created_at,.updated_at,.deleted_at,.comments,.data,.update_by,.pipeline_status_id").hide()
	})

	      function return_only_t_data(responce){
             var ajax_content_value = "</tr><tr>"
             $.each(responce, function(key, value) {
                  ajax_content_value +="<td class='"+key.replace(" ", "_")+"'style = 'border-top: 1px solid #ddd;' >"+value+"</td>" 
                  });
           ajax_content_value +="</tr>"
           return ajax_content_value
          }

          function convert_ajax_to_htm(responce){
   var ajax_content_value = "<table class = 'table table-striped'><tr class = 'table-row-header'>"
           $.each(responce, function(key, value) {
                  ajax_content_value +="<th class='"+key.replace(" ", "_")+" 'style = 'border-top: 1px solid #ddd;'>"+key.replace(/_/g," ").toUpperCase()+"</th>" 
                  });
           ajax_content_value += "</tr><tr>"
             $.each(responce, function(key, value) {
                  ajax_content_value +="<td class='"+key.replace(" ", "_")+"'style = 'border-top: 1px solid #ddd;' >"+value+"</td>" 
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
var monthNames = [ "Jan",   "Feb", "Mar",    "Apr",
                   "May",       "Jun",     "Jul",     "Aug",
                   "Sept", "Oct",  "Nov", "Dec" ]
function table_view(responce,html_value){
   $.each( responce, function( index, value ){
                if (index  ==  0){
                  html_value = "<table class ='table table-striped'><tr class ='table-row-header'>"
           $.each(value, function(key, value) {
                  key1 = key
                  if (typeof value == 'object'){ 
                    key1 = new Date(key)
                    key1 = key1.getFullYear()+"-" + monthNames[key1.getMonth()]
                     }
                     else{
                      key1 =key.replace(/_/g," ").toUpperCase()
                     }
                  html_value +="<th class='"+key.replace(" ", "_")+" 'style = 'border-top: 1px solid #ddd;'>"+key1+"</th>" 
                  });
           html_value += "</tr><tr>"
             $.each(value, function(key, value) {
                  other_class = ""
                  attr = ""
                  if (value["total_pipeline"] > 0){other_class=" text_link"}
                  if (typeof value == 'object'){ 
                    value = value["total_pipeline"]
                  attr = "data-popup-open='popup-1'"
                     }
                  html_value +="<td class='"+key.replace(" ", "_")+other_class+"'style = 'border-top: 1px solid #ddd;'"+attr+" >"+value+"</td>" 
                  });
           html_value +="</tr>"
                }
                else{
               html_value += "</tr><tr>"
             $.each(value, function(key, value) {
                  other_class = ""
                  if (value["total_pipeline"] > 0){other_class=" text_link"}
                  if (typeof value == 'object'){ value = value["total_pipeline"] }
                  html_value +="<td class='"+key.replace(" ", "_")+other_class+"'style = 'border-top: 1px solid #ddd;'"+attr+" >"+value+"</td>" 
                  });
           html_value +="</tr>"
                }
            });
                return html_value
}