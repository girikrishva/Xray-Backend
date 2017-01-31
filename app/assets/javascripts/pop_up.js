 $(document).one('ready',function(){
         
          var current_element = null
          $(".delivery_health").on('click',function(){
            var id = $(this).attr('id')
           $(".ajax_content").html(convert_ajax_to_htm(ajax_call("project_pop_up?id="+id)))
           $(".ajax_content").prepend('<input type="checkbox" class="project_detail" checked> &nbsp;&nbsp;  Project Detail<input type="checkbox" class="finance" checked>Financial Details ')
          $(".project_detail").on('click',function(){
            $(".Description,.Start_date,.End_date,.Updated_by,.Project_type").toggle();
          })
           $(".finance").on('click',function(){
            $(".Unpaid_amount,.Paid_amount,.Invoiced_amount,.Missed_payments,.Missed_invoicing,.Missed_delivery").toggle();
          })
           $(".project_detail,.finance").click()
           $(".Delivery_Health").last().css('background',$(".Delivery_Health").last().text());
           $(".contribution").last().addClass("text_link")
           $(".Gross_Profit:eq(2)").addClass("text_link")
           $(".contribution").last().on('click',function(){
            $(".hide_it").html("")
            if (current_element != null){current_element.css('background','white')}
            current_element = $(this)
            current_element.css('background','yellow')
            responce  = ajax_call("http://beta.json-generator.com/api/json/get/4k0ezyvLf")
            var html_value = "<div class= 'hide_it'><span id='close' style='cursor:pointer' hidden></span>"+ convert_ajax_to_htm(responce["result"])
            $.each( responce["result"]["data"], function( index, value ){
                if (index  ==  0){
                  html_value += convert_ajax_to_htm(value).replace("</table>","")
                }
                else{
                  html_value += return_only_t_data(value)
                }
            });
            html_value += "</table></div>"
            $(".ajax_content").append(html_value)
            $(".hide_it").hide()
            $(".hide_it").show(1000)
            $(".data").hide()
           
            $(".assigned_resource").hide()
              })
              $(".Gross_Profit:eq(2)").on('click',function(){
              if (current_element != null){current_element.css('background','white')}
             $(".hide_it").fadeOut( 1000, function(){
              $(this).remove()
             })
              current_element = $(this)
              current_element.css('background','yellow')
              responce  = ajax_call("http://beta.json-generator.com/api/json/get/4k0ezyvLf")
              var html_value = "<div class= 'hide_it'><span id='close' style='cursor:pointer' hidden></span>"+ convert_ajax_to_htm(responce["result"])
             $(".ajax_content").append(html_value)
            $(".hide_it").hide()
            $(".hide_it").show(1000)
            $(".data").hide()
          })
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