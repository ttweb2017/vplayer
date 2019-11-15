import 'dart:convert';

import 'package:flutter/foundation.dart' as foundation;
import 'package:http/http.dart' as http;
import 'package:karaoke/Constants.dart';
import 'package:karaoke/model/song.dart';

import 'singer.dart';

class AppStateModel extends foundation.ChangeNotifier {
  // All the available singers.
  List<Singer> _availableSingers;

  // All the available songs
  List<Song> _availableSongs;

  // The currently selected category of singers.
  Category _selectedCategory = Category.all;

  Category get selectedCategory {
    return _selectedCategory;
  }

  // The currently selected category of singers.
  Singer _selectedSinger;

  Singer get selectedSinger {
    return _selectedSinger;
  }

  // Returns a copy of the list of available singers, filtered by category.
  List<Singer> getSingers() {
    if (_availableSingers == null) {
      return [];
    }

    if (_selectedCategory == Category.all) {
      return List.from(_availableSingers);
    } else {
      return _availableSingers.where((p) {
        return p.category == _selectedCategory;
      }).toList();
    }
  }

  // Returns a copy of the list of available songs, filtered by category.
  List<Song> getSongs() {
    if (_availableSongs == null) {
      return [];
    }

    if (_selectedSinger == null) {
      return List.from(_availableSongs);
    } else {
      return _availableSongs.where((p) {
        return p.singer == _selectedSinger;
      }).toList();
    }
  }

  // Search the singer catalog
  List<Singer> search(String searchTerms) {
    return getSingers().where((singer) {
      return singer.name.toLowerCase().contains(searchTerms.toLowerCase());
    }).toList();
  }

  // Search the song
  List<Song> searchSong(String searchTerms) {
    return getSongs().where((song) {
      return song.name.toLowerCase().contains(searchTerms.toLowerCase())
          || song.singer.name.toLowerCase().contains(searchTerms.toLowerCase());
    }).toList();
  }

  List<Song> searchSongBySinger(Singer singer){
    return getSongs().where((song) {
      return song.singer.id == singer.id;
    }).toList();
  }
  // Returns the singer instance matching the provided id.
  Singer getSingerById(int id) {
    return _availableSingers.firstWhere((p) => p.id == id);
  }

  // Returns the song instance matching the provided id.
  Song getSongById(int id) {
    return _availableSongs.firstWhere((p) => p.id == id);
  }

  // Loads the list of available singers from the repo.
  void loadSingers() async {
    //_availableSingers = SingersRepository.loadSingers(Category.all);
    _availableSingers = await _fetchSingers();
    notifyListeners();
  }

  void loadSongs() async {
    _availableSongs = await _fetchSongs();
    notifyListeners();
  }

  void loadData(){
    // Load Singers list
    loadSingers();

    // Load Songs
    loadSongs();
  }

  void setCategory(Category newCategory) {
    _selectedCategory = newCategory;
    notifyListeners();
  }

  void setSinger(Singer newSinger) {
    _selectedSinger = newSinger;
    notifyListeners();
  }

  //Play selected song
  void playSong(int songId){

  }

  // Adds a product to the cart.
  /*void addProductToCart(int productId) {
    if (!_productsInCart.containsKey(productId)) {
      _productsInCart[productId] = 1;
    } else {
      _productsInCart[productId]++;
    }

    notifyListeners();
  }*/

  //Method to get singer list from server
  Future<List<Singer>> _fetchSingers() async {
    List<Singer> singerList = List<Singer>();

    try{
      final response = await http.get(
          Constants.SINGERS_URL
      );

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        var singers = json.decode(response.body) as List;

        singerList = singers.map((i) => Singer.fromJson(i)).toList();

        singerList.forEach((singer) {
          print("Singers: " + singer.id.toString());
        });

        print("Karaoke response: " + response.statusCode.toString());

        return singerList;

      } else {
        // If that response was not OK, throw an error.
        print("Karaoke response code: " + response.statusCode.toString());
      }
    }catch(e){
      print("Could not connect to api. Check internet connectivity! Reason: " + e.toString());
    }

    return null;
  }

  //Method to get song list from server
  Future<List<Song>> _fetchSongs() async {
    List<Song> songList = List<Song>();

    try{
      final response = await http.get(
          Constants.VIDEO_URL
      );

      if (response.statusCode == 200) {
        // If server returns an OK response, parse the JSON.
        var songs = json.decode(response.body) as List;

        songList = songs.map((i) => Song.fromJson(i)).toList();

        songList.forEach((singer) {
          print("Songs: " + singer.id.toString());
        });

        print("Karaoke response: " + response.statusCode.toString());

        return songList;

      } else {
        // If that response was not OK, throw an error.
        print("Karaoke response code: " + response.statusCode.toString());
      }
    }catch(e){
      print("Could not connect to api. Check internet connectivity! Reason: " + e.toString());
    }

    return null;
  }
}