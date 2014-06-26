<%-- 
    Document   : upload
    Created on : Jun 26, 2014, 10:30:03 AM
    Author     : Bhargav
--%>
<%@ page import="java.io.*,java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.io.output.*" %>
<%@page import="java.sql.ResultSet"%>
<%@page import="java.sql.Statement"%>
<%@page import="java.sql.SQLException"%>
<%@page import="java.sql.DriverManager"%>
<%@page import="java.sql.Connection"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%            
            String rules="";
            File file;
            int maxFileSize = 50000 * 1024;
            int maxMemSize = 5000 * 1024;
            System.out.println("Entered rules block");
            ServletContext context = pageContext.getServletContext();
            //System.out.println(request.getSession().getServletContext().getRealPath("/data/"));
            String filePath = System.getProperty("java.io.tmpdir");//context.getInitParameter("file-upload");
        //filePath=request.getSession().getServletContext().getRealPath("/data/")+"\\";

            // Verify the content type
            String contentType = request.getContentType();
            System.out.println("content type is "+contentType);
            if ((contentType.indexOf("multipart/form-data") >= 0)) {

                DiskFileItemFactory factory = new DiskFileItemFactory();
                // maximum size that will be stored in memory
                factory.setSizeThreshold(maxMemSize);
                // Location to save data that is larger than maxMemSize.
                factory.setRepository(new File("c:\\temp"));

                // Create a new file upload handler
                ServletFileUpload upload = new ServletFileUpload(factory);
                // maximum file size to be uploaded.
                upload.setSizeMax(maxFileSize);
                try {
                    // Parse the request to get file items.
                    List fileItems = upload.parseRequest(request);

                    // Process the uploaded file items
                    Iterator i = fileItems.iterator();
                    while (i.hasNext()) {
                        FileItem fi = (FileItem) i.next();
                        String value = fi.getString();
                        String fieldName = fi.getFieldName();
                        System.out.println(fieldName + " : " + value);
                         if (fieldName.equals("rules")) {
                            rules = filePath + fi.getName();
                        }
                        if (!fi.isFormField()) {

                            // Get the uploaded file parameters
                            String fileName = fi.getName();
                            boolean isInMemory = fi.isInMemory();
                            long sizeInBytes = fi.getSize();
                            // Write the file
                            if (fileName.lastIndexOf("\\") >= 0) {
                                file = new File(filePath
                                        + fileName.substring(fileName.lastIndexOf("\\")));
                            } else {
                                file = new File(filePath
                                        + fileName.substring(fileName.lastIndexOf("\\") + 1));
                            }
                            fi.write(file);
                            out.println("Uploaded Filename: " + filePath
                                    + fileName + "<br>");
                        }
                    }
                    
                } catch (Exception ex) {
                    System.out.println(ex);
                    out.println(ex);
                }
            }
            
        %>
