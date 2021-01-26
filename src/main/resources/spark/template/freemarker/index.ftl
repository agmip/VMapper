<!DOCTYPE html>
<html>
    <head>
        <#include "header.ftl">
    </head>

    <body>

        <#include "nav.ftl">

        <div class="jumbotron text-center" style=";">
            <h1>ARDN Data Tools</h1> 
            <p>short description here...</p>
        </div>
        <div class="container">
            <!-- Container (About Section) -->
            <div id="about" class="container-fluid ">
                <div class="row">
                    <div class="col-sm-6">
                        <h2>About ARDN Data Tools</h2><br>
                        <h4>General description blabla...</h4><br>
                        <p>detail description blabla...</p>
                    </div>
                    <div class="col-sm-6">
                        <img  width="125%" src="https://raw.githubusercontent.com/agmip/ARDN/master/docs/images/AgMIP_workflows.jpg">
                        
                    </div>
                </div>
            </div>
            <hr>
            <!-- Container (Services Section) -->
            <div id="services" class="container-fluid text-center bg-grey">
                <h2>APPLICATIONS</h2>
                <h4>Cloud-based:</h4>
                <br>
                <div class="row slideanim">
                    <div class="col-sm-4">
                        <h3>VMapper <a href="#" onClick="window.open('${env_path_web_tools.getVMAPPER()}')"><span class="glyphicon glyphicon-new-window"></span></a></h3>
                        <p>Help create your route map between your raw data and ICASA standard</p>
                    </div>
                    <div class="col-sm-4">
                        <h3>Unit Master <a href="#" onClick="window.open('${env_path_web_tools.getUNIT_MASTER()}')"><span class="glyphicon glyphicon-new-window"></span></a></h3>
                        <p>Help evaluate your unit expression used in your data</p>
                    </div>
                </div>
                <br>
                <h4>Desktop-based:</h4>
                <br>
                <div class="row slideanim">
                    <div class="col-sm-4">
                        <h3>QuadUI <a href="#" onClick="window.open('https://github.com/agmip/quadui/releases')"><span class="glyphicon glyphicon-download-alt"></span></a></h3>
                        <p>Translate your data from ICASA standardized data into ACEB format or a certain model input file format</p>
                    </div>
                    <div class="col-sm-4">
                        <h3>ACMOUI <a href="#" onClick="window.open('https://github.com/agmip/acmoui/releases')"><span class="glyphicon glyphicon-download-alt"></span></a></h3>
                        <p>Standardize the output data from model simulation into a spreadsheet with pre-defined format</p>
                    </div>
                    <div class="col-sm-4">
                        <h3>AcebViewer <a href="#" onClick="window.open('https://github.com/agmip/acebviewer/releases')"><span class="glyphicon glyphicon-download-alt"></span></a></h3>
                        <p>Visualize the data from ACEB file</p>
                    </div>
                </div>
            </div>
            <hr>
            <div class="container-fluid text-left">
                <legend>Browser Support</legend>
                <p>To smoothly use the online AFSIRS, please check the following table and make sure your browser is supported.</p>
                <table class="table table-bordered table-striped text-center">
                    <tr>
                        <th style="width:16%;" title="Chrome" class="text-center"><img src="images/browsers/chrome.gif" alt="Chrome"></th>
                        <th style="width:16%;" title="Edge" class="text-center"><img src="images/browsers/edge.gif" alt="Edge"></th>
                        <th style="width:16%;" title="Firefox" class="text-center"><img src="images/browsers/firefox.gif" alt="Firefox"></th>
                        <th style="width:16%;" title="Safari" class="text-center"><img src="images/browsers/safari.gif" alt="Safari"></th>
                        <th style="width:16%;" title="Opera" class="text-center"><img src="images/browsers/opera.gif" alt="Opera"></th>                
                    </tr>
                    <tr>
                        <td>Yes</td>
                        <td>Yes</td>
                        <td>Yes</td>
                        <td>Yes</td>
                        <td>Yes</td>
                    </tr>
                </table>
                <p>* Browsers which are not included in the above might face issue while using the web site.</p>
            </div>
            <hr>
        </div>
        <#include "footer.ftl">

    </body>
</html>
