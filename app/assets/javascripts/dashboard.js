/**
 * Created by yashwant on 10/6/17.
 */


data_array1 = []
data_array2 = []
mydata3 = {}
opt3 = {}
graph_type = ""
graph_month = ""
resource_data1=[]
resource_data2=[]

mydata1={}
bench_dest_data = {}
$(document).ready(function () {
    $.ajax({
        url: "/admin/api/resource_costs_panel_data",
        context: document.body
    }).done(function (data) {
        console.log("RC===="+JSON.stringify(data))
        $.each(data.datasets[0].data, function (index, value) {
            data_array1[index] = value
        });
        $.each(data.datasets[1].data, function (index, value) {
            data_array2[index] = value
        });
          mydata1 = {
            labels: ["April", "May", "June"],
            datasets: [
                {
                    fillColor: "#23457d",
                    strokeColor: "rgba(220,220,220,1)",
                    pointColor: "rgba(220,220,220,1)",
                    pointstrokeColor: "yellow",
                    data: data_array1,
                    title: "Bench Costs"
                },
                {
                    fillColor: "#D2691E",
                    strokeColor: "rgba(151,187,205,1)",
                    pointColor: "green",
                    pointstrokeColor: "yellow",
                    data: data_array2,
                    title: "Assigned Resource Costs"
                }
            ]
        }
        new Chart(document.getElementById("canvas_StackedBar1").getContext("2d")).StackedBar(mydata1, opt1);
    });




    $.ajax({
        url: "/admin/api/resource_distribution_panel_data",
        context: document.body
    }).done(function (data) {
        $.each(data.datasets[0].data, function (index, value) {
            resource_data1[index] = value
        });
        $.each(data.datasets[1].data, function (index, value) {
            resource_data2[index] = value
        });

          bench_dest_data = {
            labels:  ["April", "May", "June"],
            datasets: [
                {
                    fillColor: "#23457d",
                    strokeColor: "rgba(220,220,220,1)",
                    pointColor: "rgba(220,220,220,1)",
                    pointstrokeColor: "yellow",
                    data: resource_data1,
                    title: "Bench Resources"
                },
                {
                    fillColor: "#D2691E",
                    strokeColor: "rgba(151,187,205,1)",
                    pointColor: "green",
                    pointstrokeColor: "yellow",
                    data: resource_data2,
                    title: "Assigned Resources"
                }
            ]
        }

        new Chart(document.getElementById("bench_dest_graph").getContext("2d")).StackedBar(bench_dest_data, opt1);

    });

    $.ajax({
        url: "/admin/api/gross_profit_panel_data",
        context: document.body
    }).done(function (data) {
        var gross_p_data = {
            labels : data.labels,
            datasets : [
                {
                    pointColor : "#6495ED",
                    strokeColor : "#6495ED",
                    pointStrokeColor : "#6495ED",
                    data : data.datasets[0].data,
                    title : "Gross Profit"
                }
            ]
        }
        new Chart(document.getElementById("grass_profit_panel").getContext("2d")).Line(gross_p_data,gp_struct);
    });




});

function setColor(area, data, config, i, j, animPct, value) {
    if (value > 35)return("rgba(220,0,0," + animPct);
    else return("rgba(0,220,0," + animPct);
}





function fctMouseDownLeft(event, ctx, config, data, other) {
    var cost_s_url = ""
    var cost_d_url = ""
    if(other != null){
        $("#dialog1").dialog('open');
    }

    console.log("=========data.datasets[other.v11].title===="+data.datasets[other.v11].title)

    graph_type = data.datasets[other.v11].title
    graph_month = data.labels[other.v12]
    vv = graph_type + " Details for the month of " + graph_month
    $("#dialog1").dialog({ title: vv });

    if (data.datasets[other.v11].title == "Assigned Resource Costs") {
        cost_s_url = "/admin/api/assigned_costs_by_skill_panel_data?as_on="
        cost_d_url = "/admin/api/assigned_costs_by_designation_panel_data?as_on="
    }
    else if (data.datasets[other.v11].title == "Bench Costs") {
        cost_s_url = "/admin/api/bench_costs_by_skill_panel_data?as_on="
        cost_d_url = "/admin/api/bench_costs_by_designation_panel_data?as_on="
    }
    else if (data.datasets[other.v11].title == "Assigned Resources") {
        cost_s_url ="/admin/api/assigned_counts_by_skill_panel_data?as_on="
        cost_d_url ="/admin/api/assigned_counts_by_designation_panel_data?as_on="
    }
    else if (data.datasets[other.v11].title == "Bench Resources") {
        cost_s_url ="/admin/api/bench_counts_by_skill_panel_data?as_on="
        cost_d_url ="/admin/api/bench_counts_by_designation_panel_data?as_on="
    }
    else if (data.datasets[other.v11].title == "Gross Profit") {
        cost_s_url ="/admin/api/gross_profit_by_business_unit_panel_data?as_on="
        cost_d_url ="/admin/api/gross_profit_versus_indirect_cost_panel_data?as_on="
    }
    as_on = '2017-06-10'




    $.ajax({
        url: cost_s_url + as_on,
        context: document.body
    }).done(function (data) {

        console.log("test data skill"+JSON.stringify(data))
        mydata3 = {
            labels: data.labels,
            datasets: [
                {
                    fillColor: data.datasets[0].backgroundColor,
                    strokeColor: "rgba(220,220,220,1)",
                    data: data.datasets[0].data,
                    axis: 1,
                    title: "2012"
                }
            ]
        }
        var i, j;
        var decal = 0.00;
        mydata1.shapesInChart = [];
        opt3 = {
            canvasBorders: true,
            graphTitle: graph_type + " Details by Skill",
            legend: true,
            inGraphDataShow: false,
            annotateDisplay: true,
            graphTitleFontSize: 18,
            barValueSpacing: 40

        }
        var myStackedBar = new Chart(document.getElementById("canvas_Bar3").getContext("2d")).StackedBar(mydata3, opt3);
    });

    $.ajax({
        url: cost_d_url + as_on,
        context: document.body
    }).done(function (data) {
        console.log("test data datasets..........."+JSON.stringify(data.datasets[0].data))
        var d_lable=''
        var d_show=false
        if (graph_type == "Gross Profit"){
            d_lable="Profits Vs Indirect Costs for the current month"
            d_show=true
        }else{
            d_lable=graph_type + " Details by Designation"
            d_show=false
        }
        dis_data = {
            labels: data.labels,
            datasets: [
                {
                    fillColor: data.datasets[0].backgroundColor,
                    strokeColor: "rgba(220,220,220,1)",
                    data: data.datasets[0].data,
                    axis: 1,
                    title: "2012"
                }
            ]
        }
        var i, j;
        var decal = 0.00;
        mydata1.shapesInChart = [];
        dis_opt = {
            canvasBorders: true,
            graphTitle: d_lable ,
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
                    data: [data.datasets[0].data[0]],
                    fillColor: "#D2691E",
                    title: "Indirect Costs"
                },
                {
                    data: [data.datasets[0].data[1]],
                    fillColor: "#6495ED",
                    title: "Gross Profits,"
                }
            ]
        }
        if (graph_type == "Gross Profit"){
            var myStackedBar = new Chart(document.getElementById("canvas_Bar4").getContext("2d")).Pie(gp_pie_data, dis_opt);
            $.ajax({
                url: "/admin/api/overall_delivery_health?as_on="+"2017-03-14",
                context: document.body
            }).done(function (data) {
                $("#myTable").remove()
                d_h={}
                tab=""
                jQuery.each(data, function (name, value) {
                    if (d_h[value.delivery_health] == undefined) {
                        d_h[value.delivery_health] = 1
                    }else {
                        d_h[value.delivery_health] = d_h[value.delivery_health] + 1
                    }
                });
                tab="<table id='myTable'><thead><th>Sl No</th><th>Project Health</th><th>Count of Projects</th></thead><tbody>"
                i=0
                jQuery.each(d_h, function (name, value) {
                    i=i+1
                    tab=tab+"<tr><td>"+i+"</td><td>"+name+"</td><td>"+value+"</td></tr> "
                });
                tab=tab+"</tbody></table>"
                $("#dialog1").append(tab)
            })

        }
        else{
            var myStackedBar = new Chart(document.getElementById("canvas_Bar4").getContext("2d")).StackedBar(dis_data, dis_opt);
        }
    });
}


var startWithDataset = 1;
var startWithData = 1;
var opt1 = {
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
    mouseDownLeft: fctMouseDownLeft
}

var gp_struct = {
    canvasBorders : true,
    canvasBordersWidth : 3,
    canvasBordersColor : "black",
    datasetFill : false,
    graphTitle : " ",
    graphTitleFontSize: 18,
    graphMin : 2500000,
    yAxisMinimumInterval : 5,
    bezierCurve: false,
    annotateDisplay : true,
    inGraphDataShow : true,
    mouseDownLeft : fctMouseDownLeft
//    mouseDownRight : fctMouseDownRight,
//    mouseDownMiddle : fctMouseDownMiddle,
//    mouseMove : fctMouseMove,
//    mouseOut : fctMouseOut


}



window.onload = function () {

    $("#dialog1").dialog({
        modal: true,
        autoOpen: false
    });

    $("#dialog2").dialog({
        modal: true,
        autoOpen: false
    });

}
