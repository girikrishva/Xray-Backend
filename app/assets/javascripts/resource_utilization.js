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
  $( "#datepicker" ).datepicker({ dateFormat: 'yy-mm-dd' });
  var fullDate = new Date()
  var twoDigitMonth = ((fullDate.getMonth().length+1) === 1)? (fullDate.getMonth()+1) : '0' + (fullDate.getMonth()+1);
  var currentDate = fullDate.getDate() + "/" + twoDigitMonth + "/" + fullDate.getFullYear();
    responce  = ajax_call("api/resource_distribution_combos?as_on="+currentDate)
    var html_value = ""
     $.each( responce["data"], function( index, value ){
      value1 = Object.assign(value, value["resource_details"]);

         if (index  ==  0){
                  html_value += convert_ajax_to_htm(value1).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value1)
                }


      })
      $("#initial_table").html(html_value) 
      $("#initial_table").find('table').first().addClass("semi-transparent-table")
  $(".semi-transparent-table").find(".table-row-header").first().attr('style', 'background-color: #23457d !important; color: #FFF !important');
  
            sorting_table($("#initial_table").find('table'))

  $(".skill_id,.designation_id,.business_unit_id,.breadcrumb").hide()
      $("#datepicker").val(currentDate)
         $.each($("td.count"), function( index1, value1 ){
        $(this).addClass("text_link")
        $(this).attr('data-popup-open', 'popup-1');
      }) 
        $(".count").on('click',function(){
          skill = $(this).parent().find(".skill_id").html()
              business_unit_id = $(this).parent().find(".business_unit_id").html()
              designation = $(this).parent().find(".designation_id").html()
    responce  = ajax_call("api/resource_details?as_on="+currentDate+"&designation_id="+designation+"&skill_id="+skill+"&business_unit_id="+business_unit_id+"&with_details=true")
    var html_value = "<span id='close' style='cursor:pointer' hidden></span>"
     $.each( responce["data"], function( index, value ){
         if (index  ==  0){
                  html_value += convert_ajax_to_htm(value).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value)
                }
     })
     $(".ajax_content").html(html_value)
    sorting_table($(".ajax_content").find('table'))

     $(".modal-header").append("<span class= 'hiddding_header'style='font-family: fantasy;font-size: 20px;align-self: center;margin-top: 290px;margin-left: 260px;'> Business Unit "+$(this).parent().find(".business_unit").html()+" Skilled with "+$(this).parent().find(".skill").html()+" and Designated as "
      +$(this).parent().find(".designation").html()+"</span>")
                $(".hiddding_header").hide()
                $(".hiddding_header").last().show()
    $(".created_at,.updated_at,.deleted_at,.comments,.data,.resource_efficiency_details").hide()

  })
    $(".resource_details,.pagination_information,.pagination").hide()
  })
  $(".assigned_percent,.clocked_percent,.utilization_percent,.billing_details").on('click',function(){
    var id = $(this).attr('id').split("_")[1]
    var from = $('#q_as_on_gteq_datetime').val()
    var to = $('#q_as_on_lteq_datetime').val()
		responce  = ajax_call("api/resource_efficiency?admin_user_id="+id+"&from_date="+from+"&to_date="+to+"&with_details=true")
		var html_value = "<span id='close' style='cursor:pointer' hidden></span>"
    html_value += convert_ajax_to_htm(responce["data"])        
		$(".ajax_content").html(html_value)
    if( (jQuery.inArray("clocked_percent",$(this).attr('class').split(" ")))== 0){
    $(".popup").find(".working_hours,.bill_rate,.assigned_percentage,.clocked_percentage,.utilization_percentage,.billing_opportunity_loss").hide()
    }
    if( (jQuery.inArray("assigned_percent",$(this).attr('class').split(" ")))== 0){
    $(".popup").find(".clocked_hours,.bill_rate,.assigned_percentage,.clocked_percentage,.utilization_percentage,.billing_opportunity_loss").hide()
    }
     if( (jQuery.inArray("utilization_percent",$(this).attr('class').split(" ")))== 0){
    $(".popup").find(".assigned_hours,.bill_rate,.assigned_percentage,.clocked_percentage,.utilization_percentage,.billing_opportunity_loss").hide()
    }
    if( (jQuery.inArray("billing_details",$(this).attr('class').split(" ")))== 0){
    $(".popup").find(".clocked_hours,.assigned_percentage,.clocked_percentage,.utilization_percentage,.billing_opportunity_loss").hide()
    }
		$(".created_at,.updated_at,.deleted_at,.comments,.data,.staffing_required_details").hide()
})



    $(".deployable_resources").on('click',function(){
    var id = $(this).attr('id')
    var from = $('#q_as_on_gteq_datetime').val()
    var to = $('#q_as_on_lteq_datetime').val()
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
                  ajax_content_value +="<td class='"+key.replace(" ", "_")+"'style = 'border: 1px solid #ddd;' >"+value+"</td>" 
                  });
           ajax_content_value +="</tr>"
           return ajax_content_value
          }

          function convert_ajax_to_htm(responce){
   var ajax_content_value = "<table class = 'table table-striped'><tr class = 'table-row-header'>"
           $.each(responce, function(key, value) {
                  ajax_content_value +="<th class='"+key.replace(" ", "_")+" sort_up 'style = 'border: 1px solid #ddd;'>"+key.replace(/_/g," ").toUpperCase()+"</th>" 
                  });
           ajax_content_value += "</tr><tr>"
             $.each(responce, function(key, value) {
                  ajax_content_value +="<td class='"+key.replace(" ", "_")+"'style = 'border: 1px solid #ddd;' >"+value+"</td>" 
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

     $("#datepicker").on('change',function(){
      
        currentDate = $(this).val()
          responce  = ajax_call("api/resource_distribution_combos?as_on="+currentDate)
    var html_value = ""
     $.each( responce["data"], function( index, value ){
      value1 = Object.assign(value, value["resource_details"]);

         if (index  ==  0){
                  html_value += convert_ajax_to_htm(value1).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value1)
                }


      })

      $("#initial_table").html(html_value)
      $(".resource_details,.pagination_information").hide() 
      $(".skill_id,.designation_id,.business_unit_id").hide()
         $.each($("td.count"), function( index1, value1 ){
        $(this).addClass("text_link")
        $(this).attr('data-popup-open', 'popup-1');

      })
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
    if ($("#initial_table").html() == ""){
        $("#initial_table").html("<span style ='margin-left: 450px;'><b>No Records Found For Date: "+currentDate+"</b></span>")
      }
      })
});
