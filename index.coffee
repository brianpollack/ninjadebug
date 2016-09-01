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
    ##|  Output a string from a number padded right to a given string length
    pad: (value, maxSpace, colorFunction)->

        if !value?
            value = "<null>"

        if typeof value == "number"
            str = numeral(value).format(@debugNumberFormat)
            str = " " + str while str.length < maxSpace

            if colorFunction? then return colorFunction(str)
            return chalk.cyan(str)

        str = value
        str = str + " " while str.length < maxSpace
        if colorFunction? then return colorFunction(str)
        return str

    constructor: ()->

    dumpNumber : (value)->
        if @debugNumberFormat?
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
            str += @dumpObject(value, indent)
            return str

        if /function Array/.test prototype

            all = []
            for subItem in value
                all.push @dumpVar(subItem, indent)

            str = chalk.bold("[") + all.join(", ") + chalk.bold("]")
            return str

        return "type=#{type}, con=" + value.constructor.toString()

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

        return str;

    dump : (title, items...)->

        if !title? then title = ""
        title += " " while title.length < 20
        str = chalk.white(title) + " = "
        for item in items
            str += @dumpVar item, ""

        console.log str


module.exports = new Ninja()