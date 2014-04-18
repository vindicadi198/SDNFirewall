/* 
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

var count = 0;
var table_data;
function add(tableName) {
    console.log(tableName);
    //$("#search_items").append("<h1>helo</h1>");

    var dropdwn = '<div class="col-sm-4">\
    <div class="input-group">\
      <input type="text" class="form-control" id="filter' + count + '">\
      <div class="input-group-btn">\
        <button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown"><span class="caret"></span></button>\
        <ul class="dropdown-menu pull-right" id="options' + count + '" style="height:100px;overflow:auto">\
        </ul>\
      </div>\
    </div>\
  </div>';
    $("#search_items").append("<div class='form-group'>" + dropdwn + "<button type='button' class='btn btn-danger' onclick='del($(this))'><span class='glyphicon glyphicon-minus ' ></span></button><div class='col-sm-7'><input type='text' class='form-control' id='filter_text" + count + "'></div></div>");
    addDropDownMenu(count, tableName);
    count++;
}

function addDropDownMenu(cnt, tableName) {
    console.log("adding drop down");
    //console.log(new Array(getJSONData("/data/tables.json",'users')));
    if (table_data!==undefined) {
        console.log(table_data);
        var i = 0;
        $.each(table_data, function(val_key, val_val) {
            $("#options" + cnt).append('<li id="optn_' + cnt + '_ind_' + i + '" onclick="setText($(this))"><a >' + val_val.name + '</a></li>');
            i++;
        });
    } else {
        $.getJSON("data/tables.json", function(obj)
        {
            console.log(obj);
            table_data = obj[tableName];
            //console.log(obj['hardware details'][0].name);
            var i = 0;
            $.each(table_data, function(key, value)
            {
                console.log(table_data);
                console.log(key + " : " + value);
                console.log("#options" + cnt);
                console.log(value);

                $("#options" + cnt).append('<li id="optn_' + cnt + '_ind_' + i + '" onclick="setText($(this))"><a >' + value.name + '</a></li>');
                i++;

            });

        });
    }
}

function del($element) {
    $element.parent().remove();
}

function setText(object) {
    console.log(object.attr("id").split("_")[2]);
    var vals = object.attr("id").split("_");
    console.log(vals);
    $("#filter" + vals[1]).val(object.text());
    $("#filter_text" + vals[1]).removeAttr("name");
    $("#filter_text" + vals[1]).attr("name", table_data[vals[3]]["field name"]);
    $("#filter_text" + vals[1]).attr("placeholder", table_data[vals[3]]["name"]);
}

function send(tableName) {
    console.log($("#search_items").serialize() + "&tableName=users");
    $.ajax({url: "searchQuery.jsp", data: $("#search_items").serialize() + "&tableName=" + tableName, success: function(result) {
            $("#result_panel").css("visibility", "visible");
            $("#table_data").html(result);
            alert(result);
        }});
}

function edit(pkey,pkeyval,tableName) {
    //console.log("prevMac=" + prevMac + "&" + $("#edit_form").serialize());
    $.ajax({url: "editExec.jsp",data: "pkey=" + pkey + "&" + "pkeyval=" + pkeyval + "&" + "tableName="+tableName +"&" + $("#edit_form").serialize(), success: function(result) {
            alert(result);
            //$("#result_panel").css("visibility","visible");
            //$("#table_data").html(result);
        }});

}

function delete_rec(pkey,pkeyval,tableName) {
    //console.log("prevMac=" + prevMac + "&" + $("#edit_form").serialize());
    $.ajax({url: "delExec.jsp", data: "pkey=" + pkey + "&" + "pkeyval=" + pkeyval + "&" + "tableName="+tableName +"&" + $("#edit_form").serialize(), success: function(result) {
            alert(result);
            //$("#result_panel").css("visibility","visible");
            //$("#table_data").html(result);
        }});

}


function post_to_url(path, params, method) {
    method = method || "post"; // Set method to post by default if not specified.

    // The rest of this code assumes you are not using a library.
    // It can be made less wordy if you use one.
    var form = document.createElement("form");
    form.setAttribute("method", method);
    form.setAttribute("action", path);

    for(var key in params) {
        if(params.hasOwnProperty(key)) {
            var hiddenField = document.createElement("input");
            hiddenField.setAttribute("type", "hidden");
            hiddenField.setAttribute("name", key);
            hiddenField.setAttribute("value", params[key]);

            form.appendChild(hiddenField);
         }
    }

    document.body.appendChild(form);
    form.submit();
}