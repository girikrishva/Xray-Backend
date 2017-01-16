 $(document).one('ready',function(){
         

          $(".delivery_health").on('click',function(){
           $(".ajax_content").html(convert_ajax_to_htm(ajax_call("project_pop_up?id="+$(this).attr('id'))))
            $(".Project").on('click',function(){
            $(".ajax_content").html(convert_ajax_to_htm(ajax_call("http://beta.json-generator.com/api/json/get/4y3lXT0HM")))
             
           })
          })

          function convert_ajax_to_htm(responce){
   var ajax_content_value = "<table><tr>"
           $.each(responce, function(key, value) {
                  ajax_content_value +="<th style = 'border: 1px solid black;'>"+key+"</th>" 
                  });
           ajax_content_value += "</tr><tr>"
             $.each(responce, function(key, value) {
                  ajax_content_value +="<td class='"+key+"'style = 'border: 1px solid black;' >"+value+"</td>" 
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