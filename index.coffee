chalk   = require 'chalk'
moment  = require 'moment'
numeral = require 'numeral'

##| Ninja main class which is exported as a general purpose set of debugging tools
##|
globalNinjaInstance = null

class Ninja

    # Format to use to display numbers, set to null for no output
    debugNumberFormat : '#,###.[####]'

    # Format to use to display dates, set to null for no output
    debugDateFormat   : 'dddd, MMMM Do YYYY, h:mm:ss a'

    ##|
    ##|  Returns a text formatted value for a decimal that is a percent
    dumpPercent: (value)->
        if !value? then value = 0
        return numeral(value).format('#,### %')

    ##|
    ##|  Output a string from a number padded right to a given string length
    pad: (value, maxSpace, colorFunction, customFormat)->

        if !value?
            value = "<null>"

        if typeof value == "number" and isNaN(value)
            value = "<isNaN>"

        if typeof value == "number"
            if customFormat?
                str = numeral(value).format(customFormat)
            else
                str = numeral(value).format(@debugNumberFormat)

            str = " " + str while str.length < maxSpace

            if colorFunction? then return colorFunction(str)
            return chalk.cyan(str)

        str = value.toString()
        str = str + " " while str.length < maxSpace
        if colorFunction? then return colorFunction(str)
        return str

    constructor: ()->

    dumpNumber : (value)->
        if isNaN(value)
            return chalk.gray("<isNaN>")

        if @debugNumberFormat?
            if !value? then return @dumpNull()
            return chalk.cyan(numeral(value).format(@debugNumberFormat))
        return chalk.cyan(value)

    dumpString: (value)->
        return "'" + chalk.magenta(value) + "'"

    dumpBoolean: (value)->
        return chalk.green(value)

    dumpDate: (value)->
        if @debugDateFormat?
            return chalk.yellow(moment(value).format(@debugDateFormat))
        return chalk.yellow(value)

    dumpNull: ()->
        return chalk.gray("<null>")

    dumpVar : (value, indent)->

        type = typeof value
        if !value?
            return @dumpNull()

        if type == "string"
            return @dumpString(value)

        if type == "number"
            return @dumpNumber(value)

        if type == "boolean"
            return @dumpBoolean(value)

        if value.getTime?
            return @dumpDate(value)

        prototype = value.constructor.toString()
        if /function Object/.test prototype
            str  = "\n"
            str += @dumpObject(value, indent + "    ")
            return str

        if /function Array/.test prototype

            all = []
            for subItem in value
                all.push @dumpVar(subItem, indent)

            str = chalk.bold("[") + all.join(", ") + chalk.bold("]")
            return str

        if type == "function"
            return "Function()"

        str += @dumpObject(value, indent + "    ")

        # return "type=#{type}, con=" + value.constructor.toString()

    dumpObject : (item, indent)->

        maxLen = 0
        str    = ""
        for varName, valName of item
            if varName.length > maxLen then maxLen = varName.length

        for varName, value of item
            name = varName
            name = name + " " while name.length < maxLen
            str += indent + name + " : "

            if varName == "_id"
                str += value.toString();
            else
                str += @dumpVar(value, indent + "    ")

            str += "\n";

        return str.replace /\n$/, ""

    ##|
    ##|  Log will take any number of items and output them similar to console.log
    ##|  except that color is added automatically and objects are dummped nicely.
    ##|
    log : (items...)->

        level = 0
        for item in items
            if typeof item == "string" and level == 0
                level++
                process.stdout.write item
            else
                str = @dumpVar item, ""
                process.stdout.write str
                level--

        process.stdout.write "\n"

    ##|
    ##|  Dump attempts to display a variable as if it were an assignment that you
    ##|  can just copy/paste back into your code if needed.
    ##|
    dump : (title, items...)->

        if !items?
            items = title
            title = ""

        if !title? then title = ""
        str = chalk.white(title) + " = "
        for item in items
            str += @dumpVar item, ""

        console.log str


module.exports = new Ninja()