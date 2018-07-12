namespace :testing do
  # a testing rake to access the database
  desc "read subjects from the database"
  task :readsubject => :environment do
    LOAD_LOG.info  "READING SUBJECTS..."
    subject_group = SubjectGroup.find_by_name("authorized")
    subjects = subject_group.subjects
    sub_code = subjects.pluck(:subject_code)
    p sub_code


  end
  desc "determine what subjects exist"
  task :checksubjects => :environment do


    subject_list = ["2693DX","19G3HM","2756X","20B7DX","1425MX72","2071DX","3319GX","2760GXT2","26N2GXT2","22F2W","28E4X","3232GX",
      "1772XXT2","1133X","2210W","1475HX","1800xx","1889MX","2313W","28A1X","2788X","1903MX","3531GX","3335GX","2072W1T2","20A4DX",
      "3562GX61","1106X","27B2X","2844GX","2920X","3665HY","1111X","1684MX","1649XX","1732MX","14A6HX","2111DX","2072DX","1620XX",
      "21B3DX","1776MX","2149DX","1795MX","3608HY","1734XX","3450GX","1835XX","1779MX","1708xx","1304HX","2195W","2632DX","29G2X",
      "1920MX","3227GX","3539HY","2238DX","2150DX","1257V","3353GX","1120X","2104X8T2","1507HX","1490HX","2065DX","2310HM","3228GX",
      "23DHHM","3441GX","1873MX","1209V","20C1DX","3665","2196W","27P9X","2209W","27Q9GX","18E4MX","3237GX","22B1DX","1145X","1136X",
      "3536HY52","1772MX","1547MX62","27L5DX","18k1XX","1819XX","2109W","1725MX","1375HX","22T1W","24B7GXT3","21A4DX","1742MX","23CEHM",
      "2818X","18B2XX","1215H","23CDHM","2823GX","2249HM","1798mx","27D9GX","3411GX52","25R8GXT2","1834MX","2082W1T2","2768X","28A5X","1144X",
      "1750XX","3525GX","3540GX","2173DX","2152DX","3315GX32","26P7X","3445HY","26P6X7T2","3241GX63","23C2HM","3453HY52","1854MX","2123W",
      "1458HX","2929X","2140DX","1736MX","28J8X","22C5DX","1963XX","1722MX","1683XX","2419HM","20B1HM","2605DX","1213HX","1319HX","1355H",
      "3433GX","26R1X7T2","18E3XX","1637XX","1871MX","1122X","3339GX","2093HM","1105X","1691MX","2199HM","26O2GXT2","2111W","1888XX",
      "1485HX","28C9X","1851MX","2138DX","3233GX","1366HX"]

    missing = []
    sub_code = Subject.pluck(:subject_code)
    for s in subject_list
      #  if Subject.where(subject_code:s).exists?
      #   # add to a list
      #   missing.push(s)
      unless sub_code.include? s.upcase
        missing.push(s)
      end
    end
    p missing

  end



end
