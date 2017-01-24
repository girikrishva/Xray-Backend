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
	$("#page_title").text("Delivery Health")
    if ($.urlParam('q%5Bcomments_eq%5D') != null)
{
       $('#q_comments').val($.urlParam('q%5Bcomments_eq%5D'));

}
    if ($.urlParam('q%5Bbooking_value_eq%5D') != null)
{
       $('#q_booking_value').val($.urlParam('q%5Bbooking_value_eq%5D'));

}
   if ($.urlParam('q%5Bcontribution_status%5D') != null)
{
       $('#q_contribution_status').val(decodeURIComponent($.urlParam('q%5Bgross_profit_status%5D')));

}
 if ($.urlParam('q%5Bgross_profit_status%5D') != null)
{
       $('#q_gross_profit_status').val(decodeURIComponent($.urlParam('q%5Bgross_profit_status%5D')));

}
    if ($.urlParam('q%5Bproject_health%5D') != null)
{
    var health = $.urlParam('q%5Bproject_health%5D')
     $('#q_project_health').val(health);
}

           $(".contribution").on('click',function(){
            id = $(this).attr('id').split("_")[1]
            responce  = ajax_call("api/direct_resource_cost?project_id="+id+"&with_details=true")
            var html_value = "<span id='close' style='cursor:pointer' hidden></span>"+ convert_ajax_to_htm(responce)
            html_value += "<div>Detailed View</div>"
            $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value)
                }
            });
            html_value += "</table>"
            $(".ajax_content").html(html_value)
            $(".data").hide()
            $(".assigned_resource").hide()
              })

             $(".gross_profit").on('click',function(){
            id = $(this).attr('id').split("_")[1]
            responce  = ajax_call("api/direct_overhead_cost?project_id="+id+"&with_details=true")
            var html_value = "<span id='close' style='cursor:pointer' hidden></span>"+ convert_ajax_to_htm(responce)
            html_value += "<div>Project Overhead</div>"
            $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["project_overhead"]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["project_overhead"])
                }
            });
            html_value += "</table>"
            $(".ajax_content").html(html_value)
            $(".created_at,.updated_at,.deleted_at,.project_id,.comments,.data,.project_overhead,.cost_adder_type_id ").hide()
               $.each( responce["data"], function( index, value ){
                index_p1 = index + 1
                if (index  ==  0){
                  $(".ajax_content").find('table').last().find('tr:eq('+index+')').append('<th class="cost_adder_type" style="border: 1px solid black;">COST ADDER TYPE</th>')
                  $(".ajax_content").find('table').last().find('tr:eq('+index+')').append('<th class="direct_overhead_cost" style="border: 1px solid black;">DIRECT OVERHEAD COST</th>')
                  $(".ajax_content").find('table').last().find('tr:eq('+index_p1+')').append('<td class="cost_adder_type" style="border: 1px solid black;">'+value["cost_adder_type"]+'</td>')
                  $(".ajax_content").find('table').last().find('tr:eq('+index_p1+')').append('<td class="direct_overhead_cost" style="border: 1px solid black;">'+value["direct_overhead_cost"]+'</td>')
                }
                else{
                  $(".ajax_content").find('table').last().find('tr:eq('+index_p1+')').append('<td class="cost_adder_type" style="border: 1px solid black;">'+value["cost_adder_type"]+"</td>")
                  $(".ajax_content").find('table').last().find('tr:eq('+index_p1+')').append('<td class="direct_overhead_cost" style="border: 1px solid black;">'+value["direct_overhead_cost"]+"</td>")
                }
            });
              })

             $(".missed_delivery").on('click',function(){
            id = $(this).attr('id').split("_")[1]
            responce  = ajax_call("api/missed_delivery?project_id="+id+"&with_details=true")
            var html_value = "<span id='close' style='cursor:pointer' hidden></span>"+ convert_ajax_to_htm(responce)
            html_value += "<div>Delivery Milestone</div>"
            $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["delivery_milestone"]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["delivery_milestone"])
                }
            });
            html_value += "</table>"
            $(".ajax_content").html(html_value)
            $(".created_at,.updated_at,.deleted_at,.project_id,.comments,.data").hide()
              })

              $(".missed_payments").on('click',function(){
            id = $(this).attr('id').split("_")[1]
            responce  = ajax_call("api/missed_payments?project_id="+id+"&with_details=true")
            var html_value = "<span id='close' style='cursor:pointer' hidden></span>"+convert_ajax_to_htm(responce)
            html_value += "<div>Invoice Line</div>"
            $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["invoice_line"]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["invoice_line"])
                }
            });
            html_value += "</table>"
            html_value += "<div>Invoice Header</div>"
            $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["invoice_header"]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["invoice_header"])
                }
            });
            html_value += "</table>"
            $(".ajax_content").html(html_value)
            $(".created_at,.updated_at,.deleted_at,.project_id,.comments,.data").hide()

              })

               $(".missed_invoicing").on('click',function(){
            id = $(this).attr('id').split("_")[1]
            responce  = ajax_call("api/missed_invoicing?project_id="+id+"&with_details=true")
            var html_value = "<span id='close' style='cursor:pointer' hidden></span>"+ convert_ajax_to_htm(responce)
            html_value += "<div>Invoice Milestone</div>"
            $.each( responce["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value["invoicing_milestone"]).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value["invoicing_milestone"])
                }
            });
            html_value += "</table>"
            $(".ajax_content").html(html_value)
            $(".created_at,.updated_at,.deleted_at,.project_id,.comments,.data").hide()
             $.each( responce["data"], function( index, value ){
                index_p1 = index + 1
                if (index  ==  0){
                  $(".ajax_content").find('table').last().find('tr:eq('+index+')').append('<th class="Uninvoiced" style="border: 1px solid black;">Uninvoiced</th>')
                  $(".ajax_content").find('table').last().find('tr:eq('+index_p1+')').append('<td class="Uninvoiced" style="border: 1px solid black;">'+value["uninvoiced"]+'</td>')
                }
                else{
                  $(".ajax_content").find('table').last().find('tr:eq('+index_p1+')').append('<td class="Uninvoiced" style="border: 1px solid black;">'+value["uninvoiced"]+"</td>")
                }
            });
              })

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
          function return_only_t_data(responce){
             var ajax_content_value = "</tr><tr>"
             $.each(responce, function(key, value) {
                  ajax_content_value +="<td class='"+key.replace(" ", "_")+"'style = 'border: 1px solid black;' >"+value+"</td>" 
                  });
           ajax_content_value +="</tr>"
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
        })
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