import os
import psycopg2
from flask import Flask, render_template, request, url_for, redirect

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(host='localhost',
        	database="parking_db",
		      user="postgres",
          password="admin1")
    return conn


@app.route('/')
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT car_park.id_car_park, car_park.park_name, car_park.location, '
                'car_park.total_spaces, COUNT(car_park.id_car_park) FROM car_park '
                'CROSS JOIN customer '
                'WHERE customer.id_car_park = car_park.id_car_park '
                'GROUP BY car_park.id_car_park')
    carss = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', cars = carss)

@app.route('/create/', methods=('GET', 'POST'))
def create():
    if request.method == 'POST':
        DNI = request.form['DNI']
        nombre = request.form['Nombre']
        Apellidos = request.form['Apellidos']
        Email = request.form['Email']
        NumeroContacto = request.form['NumeroContacto']

        Marca = request.form['Marca']
        Modelo = request.form['Modelo']
        Matricula = request.form['Matricula']

        Aparcamiento = request.form['Aparcamiento']
        Longitud = request.form['Longitud']
        Anchura = request.form['Anchura']
        NombreAparcamiento = request.form['NombreAparcamiento']
        Tipo = request.form['Tipo']
        TipoGen = 'disabled'
        if (Tipo == 'boxcar' or Tipo == 'touring car'):
          TipoGen = 'ordinary'

        if (DNI == '' or nombre == '' or Apellidos == '' or Email == '' or Tipo == '' or
            NumeroContacto == '' or Marca == '' or Modelo == '' or Matricula == '' or 
            Aparcamiento == '' or Longitud == '' or Anchura == '' or NombreAparcamiento == '') :
          return render_template('error.html',
                errorMessage='Debe completar todos los campos del formulario') 
        
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("SELECT id_car_park FROM car_park WHERE park_name = '{}'".format(Aparcamiento))
        parkcheck = cur.fetchall()
        if (len(parkcheck) != 1):
          return render_template('error.html',
                errorMessage='No existe ningun parking con ese nombre')

        try:
          # Insertamos los datos de forma ordenada en las tablas correspondientes
          cur.execute('INSERT INTO customer '
                      '(id_customer, id_car_park, first_name, last_name, email, phone_number) VALUES '
                      "('{}','{}', '{}', '{}', '{}', '{}')".format(DNI, parkcheck[0][0], nombre, Apellidos, Email, NumeroContacto))
          
          cur.execute('INSERT INTO car '
                      '(id_customer, plate, brand, model) VALUES '
                      "('{}','{}', '{}', '{}')".format(DNI, Matricula, Marca, Modelo))
                      
          cur.execute('INSERT INTO parking_space '
                      '(id_car_park, name, availability, space_length, space_width, accesibility) VALUES '
                      "('{}','{}', false, '{}', '{}', '{}')".format(parkcheck[0][0], NombreAparcamiento, Longitud , Anchura, TipoGen))
          cur.execute('INSERT INTO reservation '
                      '(id_customer, start_time, end_time) VALUES '
                      "('{}', CURRENT_TIMESTAMP, NULL)".format(DNI, NombreAparcamiento, Longitud , Anchura, TipoGen))
        

        except psycopg2.Error as err:
          print('Error:', err)
          return render_template('error.html', errorMessage=err.diag.message_primary)
        conn.commit()
        cur.close()
        conn.close()
        return render_template('payment.html')
    if request.method == 'GET':
      conn = get_db_connection()
      cur = conn.cursor()
      cur.execute('SELECT park_name FROM car_park')
      parks = cur.fetchall()
      cur.execute('SELECT c.park_name FROM car_park AS c '
                  'CROSS JOIN parking_space AS u '
                  'WHERE u.id_car_park = c.id_car_park ')
      cur.close()
      conn.close()
      return render_template('reservate.html', parkings=parks)
      
    return redirect(url_for('index'))

@app.route('/read/', methods=('GET', 'POST'))
def read():
  if request.method == 'POST':
    table = request.form['table']
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT column_name '
                'FROM information_schema.columns '
                'WHERE table_name = \'{}\''.format(table))
    rowsNames = cur.fetchall()
    cur.execute("SELECT * FROM {}".format(table))
    rows = cur.fetchall()
    return render_template("table.html", rows=rows, table_name=table, rowNames=rowsNames)
  else:
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")
    tables = cur.fetchall()
    options = []
    for table in tables:
      options.append((table[0], table[0]))
    cur.close()
    conn.close()
    return render_template("read.html", options = options)

@app.route('/delete/', methods=('GET', 'POST'))
def delete():
  if request.method == 'POST':
    table = request.form['table']
    conn = get_db_connection()
    cur = conn.cursor()

    return redirect(url_for('deletefromtable', table=table))

  else:
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")
    tables = cur.fetchall()
    options = []
    for table in tables:
      options.append((table[0], table[0]))

    cur.close()
    conn.close()
    return render_template("delete.html", options = options)

@app.route('/deletefromtable/<table>', methods=('GET', 'POST'))
def deletefromtable(table):
  if request.method == 'POST':
    column_name = request.form['column_name']
    ID = request.form['ID']
    conn = get_db_connection()
    cur = conn.cursor()
    try:
      cur.execute("DELETE FROM {} WHERE {} = {};".format(table, column_name, ID))
    except psycopg2.Error as err:
      print('Error:', err)
      return render_template('error.html', errorMessage=err.diag.message_primary)
    conn.commit()
    return redirect(url_for("index"))

  else:

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute('SELECT column_name '
                'FROM information_schema.columns '
                'WHERE table_name = \'{}\''.format(table))
    rowsNames = cur.fetchall()

    cur.close()
    conn.close()
    return render_template("deletefromtable.html", options = rowsNames)

@app.route('/update/', methods=('GET', 'POST'))
def update():
  if request.method == 'POST':
    table = request.form['table']
    conn = get_db_connection()
    cur = conn.cursor()

    return redirect(url_for('updatefromtable', table=table))

  else:
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("SELECT tablename FROM pg_tables WHERE schemaname = 'public'")
    tables = cur.fetchall()
    options = []
    for table in tables:
      options.append((table[0], table[0]))

    cur.close()
    conn.close()
    return render_template("update.html", options = options)

@app.route('/updatefromtable/<table>', methods=('GET', 'POST'))
def updatefromtable(table):
  if request.method == 'POST':
    column_name = request.form['column_name']
    oldValue = request.form['oldValue']
    newValue = request.form['newValue']
    conn = get_db_connection()
    cur = conn.cursor()
    try:
      cur.execute("UPDATE {} SET {} = '{}' WHERE {} = '{}';".format(table, column_name, newValue, column_name, oldValue))
    except psycopg2.Error as err:
      print('Error:', err)
      return render_template('error.html', errorMessage=err.diag.message_primary)
    conn.commit()
    return redirect(url_for("index"))

  else:

    conn = get_db_connection()
    cur = conn.cursor()

    cur.execute('SELECT column_name '
                'FROM information_schema.columns '
                'WHERE table_name = \'{}\''.format(table))
    rowsNames = cur.fetchall()

    cur.close()
    conn.close()
    return render_template("updatefromtable.html", options = rowsNames)
