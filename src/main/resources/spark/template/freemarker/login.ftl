<!DOCTYPE html>
<html>
    <head>
        <#include "header.ftl">
        <style>
            th, td {
                padding: 5px;
                text-align: left;
            }
        </style>
    </head>
    <body>

        <#include "nav.ftl">

        <div class="container">

            <legend>LOGIN PAGE</legend>
            <#if operation_result == "Failed" >
            <div class="alert alert-warning">LOGIN_AUTH_FAILED</div>
            </#if>
            <form id="loginForm" method="post">
                <div class="row">
                    <div class="form-group">
                        <div class="col-sm-2"><label class="control-label">User Name :</label></div>
                        <div class="col-sm-4"><input type="text" class="form-control" name="username" placeholder="User Name" value="" required></div>
                    </div>
                </div>
                <div class="row">
                    <div class="form-group">
                        <div class="col-sm-2"><label class="control-label">Password :</label></div>
                        <div class="col-sm-4"><input type="password" class="form-control" name="password" placeholder="Passowrd" value="" required></div>
                    </div>
                </div>
                <div class="row">
                    <div class="form-group">
                        <div class="col-sm-1"><input type="submit" class="btn" value="Login"></div>
                    </div>
                </div>
            </form>
        </div>

        <#include "footer.ftl">
    </body>
</html>
