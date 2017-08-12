/**
 * Created by yashwant on 10/6/17.
 */

var bench_dest_data = {}
var as_on1 =""

$(document).ready(function () {
    load_pipeline("cache_load")
    $( "#refresh" ).click(function() {
        load_pipeline("db_load")
    });
  function load_pipeline(load) {
      $.ajax({
          url: pipeline_by_business_unit_trend,
          context: document.body
      }).done(function (data) {
          var bench_dest_data1 = {
              labels: data.labels,
              datasets: [
                  {
                      fillColor: data.datasets[0].backgroundColor,
                      strokeColor: "rgba(220,220,220,1)",
                      pointColor: "rgba(220,220,220,1)",
                      pointstrokeColor: "yellow",
                      data: data.datasets[0].data,
                      title: data.datasets[0].label
                  },
                  {
                      fillColor: data.datasets[1].backgroundColor,
                      strokeColor: "rgba(220,220,220,1)",
                      pointColor: "rgba(220,220,220,1)",
                      pointstrokeColor: "yellow",
                      data: data.datasets[1].data,
                      title: data.datasets[1].label
                  },
                  {
                      fillColor: data.datasets[2].backgroundColor,
                      strokeColor: "rgba(220,220,220,1)",
                      pointColor: "rgba(220,220,220,1)",
                      pointstrokeColor: "yellow",
                      data: data.datasets[2].data,
                      title: data.datasets[2].label
                  }
              ]
          }


          var startWithDataset = 1;
          var startWithData = 1;
          var gp_struct1 = {
              graphMin: 0,
              animationStartWithDataset: startWithDataset,
              animationStartWithData: startWithData,
              animationSteps: 200,
              canvasBorders: true,
              canvasBordersWidth: 3,
              canvasBordersColor: "black",
              graphTitle: "",
              legend: true,
              inGraphDataShow: true,
              annotateDisplay: true,
              graphTitleFontSize: 18,
              barValueSpacing: 40,
              mouseDownLeft: fctMouseDownLeft1
          }

          new Chart(document.getElementById("pipeline_chart").getContext("2d")).StackedBar(bench_dest_data1, gp_struct1);

      });
  }

});



function setColor(area, data, config, i, j, animPct, value) {
    if (value > 35)return("rgba(220,0,0," + animPct);
    else return("rgba(0,220,0," + animPct);
}


var graph_type1 = ""
var graph_month1 =""



function fctMouseDownLeft1(event, ctx, config, data, other) {

    if(other != null){
        $("#dialog2").dialog('open');
        jQuery('div[aria-describedby*="dialog2"]').attr('style','z-index: 101;  left: 30%; top: 60%;width:46% !important');
    }

    graph_type1 = data.datasets[other.v11].title
    graph_month1 = data.labels[other.v12]
    var vv1 = graph_type1 + " Details for the month of " + graph_month1
    $("#dialog2").dialog({ title: vv1 });

    console.log("====monthNames.indexOf(graph_month1)+1 == new Date().getMonth()"+monthNames.indexOf(graph_month1)+1 == new Date().getMonth())
    if (monthNames.indexOf(graph_month1) == new Date().getMonth()){
        console.log("inside 1st if")
        as_on1 = formatDate(new Date())
    }
    else{
        var currentTime = new Date();
        var yyear=[11,12].indexOf(monthNames.indexOf(graph_month1)+1) > 0 ? currentTime.getFullYear()+1 :currentTime.getFullYear()
        as_on1=formatDate(LastDayOfMonth(yyear,monthNames.indexOf(graph_month1)+1))
        console.log("inside 1st else"+as_on1)
    }

    console.log("inside 1st elseee"+as_on1)
        $.ajax({
            url: "/admin/api/pipeline_by_stage_panel_data?bu_name="+data.datasets[other.v11].title+"&as_on="+as_on1,
            context: document.body
        }).done(function (data) {


            dis_opt = {
                canvasBorders: true,
                graphTitle: "Pipeline by Stage for  "+graph_type1 ,
                legend: true,
                inGraphDataShow: false,
                annotateDisplay: true,
                graphTitleFontSize: 18,
                inGraphDataShow : true
            }
            var cc=[]


            $.each(data.datasets[0].data, function (index, value) {
                cc.push({ data: [value],fillColor: "#D2691E",title: ""})
            });

            $.each(data.labels, function (index, value) {
                cc[index].title=value
            });
            $.each(["#D2691E","#FFFF00","#808000","#00FFFF","#000080","#C0392B","#117864","#979A9A"], function (index, value) {
                cc[index].fillColor=value
            });
            console.log("cc'''''")
            console.log(cc)
            var gp_pie_data = {
                labels: [""],
                datasets:  cc
            }

            new Chart(document.getElementById("canvas_Bar8").getContext("2d")).Pie(gp_pie_data, dis_opt);

        });


}







