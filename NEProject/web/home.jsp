<%-- 
    Document   : index
    Created on : Mar 17, 2014, 8:59:41 AM
    Author     : Bhargav
--%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.sql.SQLException"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.io.*,java.util.*" %>
<%

%>
<!DOCTYPE html>
<html>
    <title>IITH Network</title>
    <link href="css/bootstrap.min.css" rel="stylesheet">
    <link href="css/bootstrap-theme.min.css" rel="stylesheet">
    <script src="js/jquery-2.1.0.min.js"></script>
    <script src="js/bootstrap.min.js"></script>
    <script src="js/advancedsearchfuncs.js"></script>
    <link href="css/theme.css" rel="stylesheet">
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>


    <%@ include file="header.jsp" %>

    <script>
        var pkeyval = "";
        $("a[href='home.jsp'").parent().addClass("active");
    </script>

    <div class="container theme-showcase" role="main" >
        <div class="row">

            <div class="col-lg-12">
                <%                    try {
                        Class.forName("org.postgresql.Driver");
                        Connection myConn = DriverManager.getConnection("jdbc:postgresql://" + getServletContext().getInitParameter("server") + ":5432/openflow", getServletContext().getInitParameter("db_user"), getServletContext().getInitParameter("db_passwd"));
                        PreparedStatement prepStmnt = myConn.prepareStatement("SELECT * FROM " + getServletContext().getInitParameter("tableName"));
                        ResultSet resSet = prepStmnt.executeQuery();
                        int colCount = resSet.getMetaData().getColumnCount();
                        out.print("<table class='table table-bordered justified table-hover'>");
                        out.print("<tr><th>Src Network</th><th>Src Prefix Length</th><th>Dst Network</th><th>Dst Prefix Length</th><th>Protocol</th><th>Port</th><th>Prority</th></tr>");
                        while (resSet.next()) {
                            out.print("<tr onclick='modalCall($(this)," + colCount + ",\"" + getServletContext().getInitParameter("tableName") + "\")'>");
                            for (int i = 1; i < colCount + 1; i++) {
                                out.print("<td name=" + resSet.getMetaData().getColumnName(i) + ">" + resSet.getString(i) + "</td>");
                            }

                            out.print("</tr>");

                        }
                        out.print("</table>");
                        prepStmnt.close();

                    } catch (ClassNotFoundException cnfe) {
                        System.err.println("Error loading driver: " + cnfe);
                    } catch (SQLException sqle) {
                        System.err.println("Error connecting: " + sqle);
                    }
                %>
            </div>
        </div>
    </div>
    <script>
        function modalCall(elmnt, cnt, tableName) {
            table_name = tableName;
            console.log(elmnt.find("td"));
            var elements = elmnt.find("td");
            modalFormSet(elements, cnt);
            console.log(cnt);
            console.log(elements);
            $('#myModal').modal();
        }

        function modalFormSet(elemnt, cnt) {
            $("#edit_form").html("");
            console.log(cnt);

            var src_network = "";
            var protocol = "";
            var src_prefix_length = "";
            var port = "";
            var dst_prefix_length = "";
            var dst_network = "";
            var priority="";

            for (var i = 0; i < cnt; i++) {
                if ($(elemnt).eq(i).attr("name") === "src_network") {
                    src_network = $(elemnt).eq(i).html();
                } else if ($(elemnt).eq(i).attr("name") === "src_prefix_length") {
                    console.log("primary key is " + i);
                    src_prefix_length = $(elemnt).eq(i).html();
                    console.log("primary key is " + i + " " + pkeyval);
                } else if ($(elemnt).eq(i).attr("name") === "dst_network") {
                    dst_network = $(elemnt).eq(i).html();
                } else if ($(elemnt).eq(i).attr("name") === "dst_prefix_length") {
                    console.log("primary key is " + i);
                    dst_prefix_length = $(elemnt).eq(i).html();
                    console.log("primary key is " + i + " " + pkeyval);
                } else if ($(elemnt).eq(i).attr("name") === "protocol") {
                    console.log("primary key is " + i);
                    protocol = $(elemnt).eq(i).html();
                    console.log("primary key is " + i + " " + pkeyval);
                } else if ($(elemnt).eq(i).attr("name") === "port") {
                    console.log("primary key is " + i);
                    port = $(elemnt).eq(i).html();
                    console.log("primary key is " + i + " " + pkeyval);
                }else if ($(elemnt).eq(i).attr("name") === "priority") {
                    console.log("primary key is " + i);
                    priority = $(elemnt).eq(i).html();
                    console.log("primary key is " + i + " " + pkeyval);
                }
                console.log("entered loop");
                $("#edit_form").append('<div class="form-group clearfix">\
<label for="' + $(elemnt).eq(i).attr("name") + '" class="col-sm-4 control-label">' + $(elemnt).eq(i).attr("name") + '</label>\
<div class="col-sm-7 clearfix">\
<input type="text" class="form-control" id="' + $(elemnt).eq(0).attr("name") + '" name="' + $(elemnt).eq(i).attr("name") + '" placeholder="' + $(elemnt).eq(i).attr("name") + '" value="' + elemnt.eq(i).html() + '" >\
</div>\
</div>');
            }
            pkeyval = "old_src_network="+src_network+"&old_src_prefix_length="+src_prefix_length+"&old_dst_network="+dst_network+"&old_dst_prefix_length="+dst_prefix_length+"&old_port"=port+"&old_protocol="+protocol+"&old_priority="+priority;
        }

    </script>
    <div class="modal fade clearfix" id="myModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <h4 class="modal-title" id="myModalLabel">Edit Block Rule</h4>
                </div>
                <div class="modal-body">
                    <form class="form-horizontal" role="form" action="edit_exec.php" method="get" id="edit_form">
                    </form>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-success" onclick="edit_rule(pkeyval)">Edit</button>
                    <button type="button" class="btn btn-danger" onclick="delete_rule()">Delete</button>
                    <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                </div>
            </div><!-- /.modal-content -->
        </div>
    </div>
</body>
</html>
