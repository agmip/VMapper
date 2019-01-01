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

            <h1>LOGIN PAGE</h1>
            <#if operation_result == "Failed" >
            <p>LOGIN_AUTH_FAILED</p>
            </#if>
            <form id="loginForm" method="post">
                <table>
                    <tr>
                        <td><label>User Name :</label></td>
                        <td><input type="text" name="username" placeholder="User Name" value="" required><br></td>
                    </tr>
                    <tr>
                        <td><label>Password :</label></td>
                        <td><input type="password" name="password" placeholder="Passowrd" value="" required><br></td>
                    </tr>
                    <tr>
                        <td><input type="submit" value="Login"></td>
                    </tr>
                </table>
            </form>
        </div>

        <#include "footer.ftl">
    </body>
</html>
