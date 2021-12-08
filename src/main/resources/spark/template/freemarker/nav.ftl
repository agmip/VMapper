<nav class="navbar navbar-default navbar-fixed-top navbar-inverse">
    <div class="container-fluid">
        <div class="navbar-header">
            <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navBar">
              <span class="glyphicon glyphicon-menu-hamburger"></span>
            </button>
            <a class="navbar-brand navbar-static-top">AgMIP</a>
        </div>
        <div class="collapse navbar-collapse" id="navBar">
            <ul class="nav navbar-nav">
                <li class="active">
                    <a href="${env_path_web_root}"><span class="glyphicon glyphicon-home"></span> Home</a>
                </li>
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-briefcase"></span> Data Tools <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="${env_path_web_tools.getVMAPPER()}"><span class="glyphicon glyphicon-road"></span> VMapper</a></li>
                        <li><a href="${env_path_web_tools.getUNIT_MASTER()}"><span class="glyphicon glyphicon-edit"></span> Unit Master</a></li>
                    </ul>
                </li>
                <li class="dropdown">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-expanded="false"><span class="glyphicon glyphicon-question-sign"></span> Help <span class="caret"></span></a>
                    <ul class="dropdown-menu" role="menu">
                        <li><a href="#" onClick="window.open('https://github.com/agmip/VMapper/issues')"><span class="glyphicon glyphicon-pencil"></span> Report Issues</a></li>
                        <li><a href="#" onClick="alertBox('VMapper Version: ${env_version!}')"><span class="glyphicon glyphicon-info-sign"></span> About VMapper</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div><!-- /container -->
</nav><!-- /navbar wrapper -->