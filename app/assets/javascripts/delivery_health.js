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
});