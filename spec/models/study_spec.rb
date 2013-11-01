require 'spec_helper'

describe Study do
  let(:nicknames) {%w(nickname1 nickname2)}
  let(:study_name) {"study_1"}

  it "should create new study with nicknames" do
    study = Study.new(official_name: study_name, nicknames: nicknames)

    study.study_nicknames.length.should == nicknames.length
    study.official_name.should == study_name

    study.study_nicknames.each {|sn| nicknames.should include sn.nickname}

    study.save

    StudyNickname.current.count.should == 2
    StudyNickname.current.each {|sn| sn.study.should == study}

  end

  it "should not orphan study nickname objects" do
    study = Study.new(official_name: study_name, nicknames: nicknames)
    study.save
  
    study.reload

    study.nicknames = []

    study.study_nicknames.should be_empty
    study.save
    study.study_nicknames.should be_empty

    StudyNickname.current.count.should == 0
  end

  it "should allow study nicknames to be added in semicolon-delimited string" do
    nickname_string = nicknames.join("; ")

    study = Study.create(official_name: study_name, nicknames: nickname_string)

    study.study_nicknames.each {|sn| nicknames.should include sn.nickname}
  end


end
