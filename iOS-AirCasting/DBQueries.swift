//
//  DBQueries.swift
//  iOS-AirCasting
//
//  Created by Renji Harold on 5/10/2015.
//  Copyright (c) 2015 Renji Harold. All rights reserved.
//

import Foundation

class DBQueries {
    
    let create_deleted_sessions = "create table if not exists deleted_sessions(id int(11), created_at datetime, updated_at datetime, uuid varchar(255), user_id int(11))"
    
    let create_measurements = "create table if not exists measurements(id int(11), value float, latitude decimal(12,9), longitude decimal(12,9), time datetime, timezone_offset int(11), stream_id int(11), milliseconds int(11), measured_value float)"
    
    let create_notes = "create table if not exists notes(id int(11), created_at datetime, updated_at datetime, date datetime, text text, latitude decimal(12,9), longitude decimal(12,9), session_id int(11), photo_file_name varchar(255), photo_content_type varchar(255), photo_file_size int(11), photo_updated_at datetime, number int(11))"
    
    let create_regressions = "create table if not exists regressions(id int(11), created_at datetime, updated_at datetime, sensor_package_name varchar(255), measurement_type varchar(255), unit_name varchar(255), unit_symbol varchar(255), threshold_very_low int(11), threshold_low int(11), threshold_medium int(11), threshold_high int(11), threshold_very_high int(11), coefficients text, sensor_name varchar(255), measurement_short_type varchar(255), reference_sensor_package_name varchar(11), reference_sensor_name varchar(11), user_id varchar(11))"
    
    let create_sessions = "create table if not exists sessions(id int(11), created_at datetime, updated_at datetime, uuid varchar(255), user_id int(11), url_token varchar(255), title text, description text, calibration int(11), contribute tinyint(1), data_type varchar(255), instrument varchar(255), phone_model varchar(255), os_version varchar(255), offset_60_db int(11), start_time datetime, end_time datetime, measurements_count int(11), timezone_offset int(11), start_time_local datetime, end_time_local datetime)"
    
    let create_streams = "create table if not exists streams(id int(11), sensor_name varchar(255), unit_name varchar(255), measurement_type varchar(255), measurement_short_type varchar(255), unit_symbol varchar(255), threshold_very_low int(11), threshold_low int(11), threshold_medium int(11), threshold_high int(11), threshold_very_high int(11), session_id int(11), sensor_package_name varchar(255), measurements_count int(11), min_latitude decimal(12,9), max_latitude decimal(12,9), min_longitude decimal(12,9), max_longitude decimal(12,9), average_value float)"
    
    let create_taggings = "create table if not exists taggings(id int(11), tag_id int(11), taggable_id int(11), taggable_type varchar(255), tagger_id int(11), tagger_type varchar(255), context varchar(255), created_at datetime)"
    
    let create_tags = "create table if not exists tags(id int(11), name varchar(255))"
    
    let create_users = "create table if not exists users(id int(11), email varchar(255), encrypted_password varchar(128), reset_password_token varchar(255), reset_password_sent_at datetime, remember_created_at datetime, sign_in_count int(11), current_sign_in_at datetime, last_sign_in_at datetime, current_sign_in_ip varchar(255), last_sign_in_ip varchar(255), authentication_token varchar(255), created_at datetime, updated_at datetime, username varchar(255), send_emails tinyint(1))"
    
    let create_parent_session = "create table if not exists parent_session(date datetime, created_at datetime, updated_at datetime, username varchar(255), user_id varchar(255), text varchar(255), session_id varchar(255), photo_file_name varchar(255), photo_content_type varchar(255), photo_file_size varchar(255), photo_updated_at datetime, sensor_package_name varchar(255), phone_model varchar(255), os_version varchar(255))"
    
    let create_measurements_sessions = "create table if not exists measurements_sessions(id varchar(255), decibel_value float, temperature_value float, particulate_matter_value float, humidity_value float, latitude decimal(12,9), longitude decimal(12,9), created_at datetime, stream_id varchar(255))"
    
    let insert_parent_session = "insert into parent_session(date, created_at, updated_at, username, user_id, text, session_id, photo_file_name, photo_content_type, photo_file_size, photo_updated_at, sensor_package_name, phone_model, os_version) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_measurements_sessions = "insert into measurements_sessions (id, decibel_value, temperature_value, particulate_matter_value, humidity_value, latitude, longitude, created_at, stream_id) values (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_measurements = "insert into measurements (id, value, latitude, longitude, time, timezone_offset, stream_id, milliseconds, measured_value) values (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_deleted_sessions = "insert into deleted_sessions (id, created_at, updated_at, uuid, user_id) values (?, ?, ?, ?, ?)"
    
    let insert_notes = "insert into notes (id, created_at, updated_at, date, text, latitude, longitude, session_id, photo_file_name, photo_content_type, photo_file_size, photo_updated_at, number) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_regressions = "insert into regressions (id, created_at, updated_at, sensor_package_name, measurement_type, unit_name, unit_symbol, threshold_very_low, threshold_low, threshold_medium, threshold_high, threshold_very_high, coefficients, sensor_name, measurement_short_type, reference_sensor_package_name, reference_sensor_name, user_id) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_sessions = "insert into sessions (id, created_at, updated_at, uuid, user_id, url_token, title, description, calibration, contribute, data_type, instrument, phone_model, os_version, offset_60_db, start_time, end_time, measurements_count, timezone_offset, start_time_local, end_time_local) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_streams = "insert into streams (id, sensor_name, unit_name, measurement_type, measurement_short_type, unit_symbol, threshold_very_low, threshold_low, threshold_medium, threshold_high, threshold_very_high, session_id, sensor_package_name, measurements_count, min_latitude, max_latitude, min_longitude, max_longitude, average_value) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_taggings = "insert into taggings (id, tag_id, taggable_id, taggable_type, tagger_id, tagger_type, context, created_at) values (?, ?, ?, ?, ?, ?, ?, ?)"
    
    let insert_tags = "insert into tags (id, name) values (?, ?)"
    
    let insert_users = "insert into users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, sign_in_count, current_sign_in_at, last_sign_in_at, current_sign_in_ip, last_sign_in_ip, authentication_token, created_at, updated_at, username, send_emails) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
}