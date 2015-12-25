package ;

import sys.io.Process;

using StringTools;
using sys.FileSystem;


/**
 * Runs `haxelib run checkstyle` for specified source directory
 *
 */
class Run
{
    /**
     * Entry point
     */
    static public function main () : Void
    {
        var r = new Run();
        r.performCheck();
    }


    /**
     * Constructor
     */
    public function new () : Void {}


    /**
     * Run checkstyle
     */
    private function performCheck () : Void
    {
        var config = getConfigPath();
        var checkPath = getCheckPath();

        var process = new Process('haxelib', ['run', 'checkstyle', '-c', config, '-s', checkPath, '-report']);
        var stdout   = process.stdout.readAll().toString().trim();
        var stderr   = process.stderr.readAll().toString().trim();
        var exitCode = process.exitCode();

        if (stdout.length > 0) Sys.println(stdout);
        if (stderr.length > 0) Sys.println(stderr);

        if (exitCode == 0) {
            var statusRegExp = ~/Total Issues: ([0-9]+)/;
            if (statusRegExp.match(stdout)) {
                exitCode = Std.parseInt(statusRegExp.matched(1));
            }
        }

        handleReport();

        Sys.exit(exitCode);
    }


    /**
     * Find checkstyle config file path
     */
    private inline function getConfigPath () : String
    {
        var process = new Process('haxelib', ['path', 'stablexui-checkstyle']);
        var stdout   = process.stdout.readAll().toString().trim();
        var stderr   = process.stderr.readAll().toString().trim();
        var exitCode = process.exitCode();
        if (exitCode != 0) {
            if (stdout.length > 0) Sys.println(stdout);
            if (stderr.length > 0) Sys.println(stderr);
            Sys.exit(exitCode);
        }

        var path = stdout.split('\n').shift();
        path = path.trim() + '../checkstyle/rules.json';

        return path.absolutePath();
    }


    /**
     * Get path to check with checkstyle
     */
    private function getCheckPath () : String
    {
        var checkPath = '.';

        var args = Sys.args();
        if (args.length == 2) {
            checkPath = args[1];
            if (!checkPath.exists()) {
                Sys.println('Path does not exist: $checkPath');
                Sys.exit(1);
            }
        }

        return checkPath;
    }


    /**
     * Remove generated reports if neccessary
     */
    private function handleReport () : Void
    {
        var args = Sys.args();
        if (args.indexOf('-r') < 0) {
            sys.FileSystem.deleteFile('check-style-report.xml');
        }
    }

}//class Run