function plot_a_mol_file
[FileName,PathName,~] = uigetfile({'*.pdb; *.ent; *.cif; *.mol; *.sdf; *.xyz; *.smol'}, 'Select a molecule');
if isnumeric(FileName)
    return
end
%[out_FileName,out_PathName,~] = uiputfile(sprintf('%s/*.html', PathName), 'Save output html');
%if isnumeric(out_FileName)
%    return
%end

html_path = sprintf('%s/%s.html', PathName, 'spinsim_viewer_tmp'); %'mol.html';
in_mol_path = FileName; %sprintf('%s%s', PathName, FileName);

fout = fopen(html_path, 'w');
fprintf(fout, '<head>\n');
fprintf(fout, '<title>spin simulation viewer (borrowed from BMRB)</title>\n');
fprintf(fout, '<script type="text/javascript" src="http://www.bmrb.wisc.edu/jsmol/jsmol/JSmoljQuery.js"></script>\n');
fprintf(fout, '<script type="text/javascript" src="http://www.bmrb.wisc.edu/jsmol/jsmol/JSmolCore.js"></script>\n');
fprintf(fout, '<script type="text/javascript" src="http://www.bmrb.wisc.edu/jsmol/jsmol/JSmolApplet.js"></script>\n');
fprintf(fout, '<script type="text/javascript" src="http://www.bmrb.wisc.edu/jsmol/jsmol/JSmolApi.js"></script>\n');
fprintf(fout, '<script type="text/javascript" src="http://www.bmrb.wisc.edu/jsmol/jsmol/j2s/j2sjmol.js"></script>\n');
fprintf(fout, '<script type="text/javascript" src="http://www.bmrb.wisc.edu/jsmol/jsmol/JSmol.js"></script>\n');
fprintf(fout, '\n');
fprintf(fout, '<script type="text/javascript">\n');
fprintf(fout, '    var jmolApplet0; // set up in HTML table, below\n');
fprintf(fout, '\n');
fprintf(fout, '    // logic is set by indicating order of USE -- default is HTML5\n');
fprintf(fout, '    var use = "HTML5"\n');
fprintf(fout, '    var s = document.location.search;\n');
fprintf(fout, '\n');
fprintf(fout, '    Jmol.debugCode = (s.indexOf("debugcode") >= 0);\n');
fprintf(fout, '\n');
fprintf(fout, '    if (s.indexOf("USE=") >= 0)\n');
fprintf(fout, '      use = s.split("USE=")[1].split("&")[0]\n');
fprintf(fout, '    else if (s.indexOf("JAVA") >= 0)\n');
fprintf(fout, '      use = "JAVA"\n');
fprintf(fout, '    else if (s.indexOf("IMAGE") >= 0)\n');
fprintf(fout, '      use = "IMAGE"\n');
fprintf(fout, '    else if (s.indexOf("NOWEBGL") >= 0)\n');
fprintf(fout, '      use = "JAVA IMAGE"\n');
fprintf(fout, '    else if (s.indexOf("WEBGL") >= 0)\n');
fprintf(fout, '      use = "WEBGL HTML5"\n');
fprintf(fout, '    if (s.indexOf("NOWEBGL") >= 0)\n');
fprintf(fout, '      use = use.replace(/WEBGL/,"")\n');
fprintf(fout, '    var useSignedApplet = (s.indexOf("SIGNED") >= 0);\n');
fprintf(fout, '\n');
fprintf(fout, '    jmol_isReady = function(applet) {}\n');
fprintf(fout, '\n');
fprintf(fout, '    var Info = {\n');
fprintf(fout, '        width: 800,\n');
fprintf(fout, '        height: 800,\n');
fprintf(fout, '        debug: false,\n');
fprintf(fout, '        color: "#FFFFFF",\n');
fprintf(fout, '        addSelectionOptions: false,\n');
fprintf(fout, '        serverURL: "http://sunfish.bmrb.wisc.edu/jsmol/jsmol/jsmol.php",\n');
fprintf(fout, '        use: use,\n');
fprintf(fout, '        jarPath: "http://www.bmrb.wisc.edu//jsmol/jsmol/",\n');
fprintf(fout, '        j2sPath: "http://www.bmrb.wisc.edu//jsmol/jsmol/j2s",\n');
fprintf(fout, '        jarFile: (useSignedApplet ? "http://www.bmrb.wisc.edu/jsmol/jsmol/JmolAppletSigned.jar" : "JmolApplet.jar"),\n');
fprintf(fout, '        isSigned: useSignedApplet,\n');
fprintf(fout, '        readyFunction: jmol_isReady,\n');
fprintf(fout, '        boxfgcolor: "#FFFFF0",\n');
fprintf(fout, '        boxbgcolor: "#FFFFF0",\n');
fprintf(fout, '        script: "set antialiasDisplay;"\n');
fprintf(fout, '    }\n');
fprintf(fout, '\n');
fprintf(fout, '\n');
fprintf(fout, '</script>\n');
fprintf(fout, '</head>\n');
fprintf(fout, '\n');
fprintf(fout, '<body>\n');
fprintf(fout, '<script>\n');
fprintf(fout, '            /* These two lines would make the jmol display take up the full width available\n');
fprintf(fout, '            Info.width = document.getElementById("jmol_display_div").offsetWidth - 50;\n');
fprintf(fout, '            Info.height = document.getElementById("jmol_display_div").offsetWidth - 50;\n');
fprintf(fout, '            */\n');
fprintf(fout, '            jmolApplet0 = Jmol.getApplet("jmolApplet0", Info);\n');
fprintf(fout, '            Jmol.loadFile(jmolApplet0,"%s");\n', in_mol_path);
fprintf(fout, '            Jmol.script(jmolApplet0,''select all;font labels 18; label %%a;wireframe; spacefill off;'')\n');
fprintf(fout, '            var lastPrompt=0;\n');
fprintf(fout, '        </script>\n');
fprintf(fout, '</body>\n');
fclose(fout);
web(html_path,'-new');
msgbox('a new web-page has opened that shows the structure file.')
