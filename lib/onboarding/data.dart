class SliderData {
  String imageURL, title, description;

  SliderData({this.description, this.imageURL, this.title});
  void setImage(String getImage) {
    imageURL = getImage;
  }

  void setDescription(String getDescription) {
    description = getDescription;
  }

  void setTitle(String getTitle) {
    title = getTitle;
  }

  String getImage() {
    return imageURL;
  }

  String getDescription() {
    return description;
  }

  String getTitle() {
    return title;
  }
}

List<SliderData> getData() {
  List<SliderData> slider = List<SliderData>();

  // first
  SliderData sliderData = SliderData();
  sliderData.setDescription("We do your laundry");
  sliderData.setImage("We provide flexible laundry services customized to the clothing you have...");
  sliderData.setTitle('assets/images/s1.jpg');

  slider.add(sliderData);

//second
  sliderData = SliderData();

  sliderData.setDescription("We cook for you");
  sliderData
      .setImage("With assorted menu's, you can get any meal ready with us");
  sliderData.setTitle('assets/images/s2.jpg');

  slider.add(sliderData);

//third
  sliderData = SliderData();

  sliderData.setDescription("and we clean your house too.");
  sliderData.setImage("We have trained cleaning personnel who will clean your house spaces.");
  sliderData.setTitle('assets/images/s3.jpg');

  slider.add(sliderData);

  return slider;
}
