#include <QTextStream>
#include <QTime>

int main()
{
   QTextStream out(stdout);

   // Get the current time
   QTime ct = QTime::currentTime();

   // Output the current time in various custom formats
   out << "The time is " << ct.toString("hh:mm:ss.zzz") << Qt::endl;
   return 0;
}