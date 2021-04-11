package hyperKitGLsamples.shiftCalendar;
import datetime.utils.DateTimeUtils;
import datetime.DateTime;
import datetime.DateTimeInterval;
import hyperKitGLsamples.shiftCalendar.ShiftDateTime;

abstract MonthLongName( DTMonth ) to DTMonth from DTMonth {
    public inline function new( m: DTMonth ){
        this = m;
    }
    @:from
    static inline public function fromString( s: String ): Null<MonthLongName> {
        return new MonthLongName( switch( s.toLowerCase() ){
            case 'january':
                return January;
            case 'february':
                return February;
            case 'march':
                return March;
            case 'april':
                return April;
            case 'may':
                return May;
            case 'june':
                return June;
            case 'july':
                return July;
            case 'august':
                return August;
            case 'september':
                return September;
            case 'october':
                return October;
            case 'november':
                return November;
            case 'december':
                return December;
            case _:
                return null;
        } );
    }
    
    @:to
    public inline function toString() {
        var m: DTMonth = cast this;
        return switch( m ){
            case January:
                return 'January';
            case February:
                return 'February';
            case March:
                return 'March';
            case April:
                return 'April';
            case May:
                return 'May';
            case June:
                return 'June';
            case July:
                return 'July';
            case August:
                return 'August';
            case September:
                return 'September';
            case October:
                return 'October';
            case November:
                return 'November';
            case December:
                return 'December';
        }
    }
    public static inline function stringFromDateTime( dt: DateTime ){
        var m: MonthLongName = cast( dt.getMonth(), DTMonth );
        var s: String = m;
        return s;
    } // trace( MonthLongName.stringFromDateTime( dateTime ) );
}

abstract WeekDayLongName( DTWeekDay ) to DTWeekDay from DTWeekDay {
    public inline
    function new( d: DTWeekDay ){
        this = d;
    }
    @:from
    static inline public function fromString( s: String ): Null<WeekDayLongName> {
        return new WeekDayLongName( switch( s.toLowerCase() ){
            case 'monday':
                return Monday;
            case 'tuesday':
                return Tuesday;
            case 'wednesday':
                return Wednesday;
            case 'thursday':
                return Thursday;
            case 'friday':
                return Friday;
            case 'saturday':
                return Saturday;
            case 'sunday':
                return Sunday;
            case _:
                return null;
        } );
    }
    
    @:to
    public inline function toString() {
        var d: DTWeekDay = cast this;
        return switch( d ){
            case Monday:
                return 'Monday';
            case Tuesday:
                return 'Tuesday';
            case Wednesday:
                return 'Wednesday';
            case Thursday:
                return 'Thursday';
            case Friday:
                return 'Friday';
            case Saturday:
                return 'Saturday';
            case Sunday:
                return 'Sunday';
        }
    }
    public static inline function stringFromDateTime( dt: DateTime, mondayBased:Bool = false ): String {
        var m: WeekDayLongName = cast( dt.getWeekDay(mondayBased), DTWeekDay );
        var s: String = m;
        return s;
    } // trace( WeekDayLongName.stringFromDateTime( dateTime ) );
}

@:forward
abstract ShiftDateTime( DateTime ) from DateTime to DateTime {
    public inline 
    function new( dateTime: DateTime ){
        this = dateTime;
    }
    public inline
    function getAnotherDay( i: Int ): ShiftDateTime {
        return new ShiftDateTime( this + Day( i ) );
    }
    
    public inline
    function getFirstWeekDay( ?mondayBased:Bool ): Int {
        var startDateForMonth = this.getMonthStart( this.getMonth() );
        return startDateForMonth.getWeekDay( mondayBased );
    }
    public inline
    function daysMonth(): Int {
        return this.daysInThisMonth();
    }
    public function getWeekdayName(): String {
        return WeekDayLongName.stringFromDateTime( this );
        /*var days = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
        var dayInt: DTWeekDay = d.getWeekDay();
        return days[ dayInt ];*/
    }
}