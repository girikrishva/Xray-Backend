/**
 * Created by yashwant on 10/6/17.
 */

var bench_dest_data = {}
var as_on =""

$(document).ready(function () {
    $.ajax({
        url: "/admin/api/pipeline_by_business_unit_trend",
        context: document.body
    }).done(function (data) {
       var bench_dest_data1 = {
            labels:  data.labels ,
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
            graphMin : 0,
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
    }

    graph_type1 = data.datasets[other.v11].title
    graph_month1 = data.labels[other.v12]
    var vv1 = graph_type1 + " Details for the month of " + graph_month1
    $("#dialog2").dialog({ title: vv1 });

    as_on = '2017-06-10'


        $.ajax({
            url: "/admin/api/pipeline_by_stage_panel_data?bu_name="+data.datasets[other.v11].title,
            context: document.body
        }).done(function (data) {
            console.log("PIEEEEEEEE"+JSON.stringify(data))

            dis_opt = {
                canvasBorders: true,
                graphTitle: "Pipeline by Stage for  "+graph_type1 ,
                legend: true,
                inGraphDataShow: false,
                annotateDisplay: true,
                graphTitleFontSize: 18,
                inGraphDataShow : true
            }

            var gp_pie_data = {
                labels: [""],
                datasets: [
                    {
                        data: [30],
                        fillColor: "#D2691E",
                        title: "New"
                    },
                    {
                        data: [20],
                        fillColor: "#6495ED",
                        title: "Discussion"
                    }
                ]
            }

            new Chart(document.getElementById("canvas_Bar8").getContext("2d")).Pie(gp_pie_data, dis_opt);

        });


}







