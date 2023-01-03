import os
import psycopg2
from flask import Flask, render_template, request, url_for, redirect

app = Flask(__name__)

def get_db_connection():
    conn = psycopg2.connect(host='localhost',
        	database="flask_db",
        # user=os.environ['DB_USERNAME'],
		user="p7",
		# password=os.environ['DB_PASSWORD']
        password="p7passwd")
    return conn


@app.route('/')
def index():
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('SELECT * FROM books;')
    books = cur.fetchall()
    cur.close()
    conn.close()
    return render_template('index.html', books=books)

@app.route('/create/', methods=('GET', 'POST'))
def create():
    if request.method == 'POST':
        title = request.form['title']
        author = request.form['author']
        pages_num = int(request.form['pages_num'])
        review = request.form['review']

        if (title == '' or author == '' or request.form['pages_num'] == '' or review == '') :
          return render_template('error.html',
                errorMessage='Debe completar todos los campos del formulario') 


        conn = get_db_connection()
        cur = conn.cursor()
        
        try:
          cur.execute('INSERT INTO books (title, author, pages_num, review)'
                      'VALUES (%s, %s, %s, %s)',
                      (title, author, pages_num, review))
        except psycopg2.Error as err:
          print('Error:', err)
          return render_template('error.html', errorMessage=err.diag.message_primary)
        conn.commit()
        cur.close()
        conn.close()
        return redirect(url_for('index'))

    return render_template('create.html')

@app.route('/delete/', methods=('GET', 'POST'))
def delete():
    delbook = None
    deleted = False
    requestedID = None
    if request.method == 'POST':
        requestedID = request.form['id']
        conn = get_db_connection()
        cur = conn.cursor()
        if (requestedID == '') :
          return render_template('error.html',
            errorMessage='Debe proporcioar un ID')
        cur.execute('SELECT * FROM books WHERE id = \'' + requestedID + '\';')
        delbook = cur.fetchall()
        
        if len(delbook) == 0:
          delbook = None
          
        else:
          cur.execute('DELETE FROM books ' +
                      'WHERE id = \'' + requestedID + '\';')
          delbook = delbook[0]
        
        deleted = True
          
        conn.commit()
        cur.close()
        conn.close()
        #return redirect(url_for('index'))

    return render_template('delete.html', book = delbook, delFlag = deleted, reqID = requestedID)

@app.route('/modify/', methods=('GET', 'POST'))
def requestmodify():
    book = None
    modified = False
    requestedID = None
    newbook = None
    if request.method == 'POST':
      requestedID = request.form['id']

      conn = get_db_connection()
      cur = conn.cursor()

      # Check id is saved
      isIn = False
      if (requestedID == '') :
        return render_template('error.html',
          errorMessage='Debe proporcioar un ID')
      cur.execute('SELECT * FROM books WHERE id = \'' + requestedID + '\';')
      newbook = cur.fetchall()
      if len(newbook) == 0:
        # newbook = newbook[0]
        return render_template('error.html', errorMessage = 'Book with Id = 2 does not exist.') 



      title = request.form['title']
      author = request.form['author']
      pages_num = int(request.form['pages_num'])
      review = request.form['review']

      if (title == '' or author == '' or request.form['pages_num'] == '' or review == '') :
        return render_template('error.html',
          errorMessage='Debe completar todos los campos del formulario') 
      
      try:
        cur.execute('UPDATE books '
                    'SET title = %s, '
                    'author = %s, '
                    'pages_num = %s, '
                    'review = %s '
                    'WHERE id = %s;',
                    (title, author, pages_num, review, requestedID))
      except psycopg2.Error as err:
        print('Error:', err)
        return render_template('error.html', errorMessage=err.diag.message_primary)
      modified = True
      cur.execute('SELECT * FROM books WHERE id = \'' + requestedID + '\';')
      newbook = cur.fetchall()
      
      if len(newbook) == 0:
        newbook = None
      else:
        newbook = newbook[0]
      conn.commit()
      cur.close()
      conn.close()

    return render_template('modify.html', bookdata = book, modFlag = modified, reqID = requestedID, book = newbook)

@app.route('/about/', methods=('GET', 'POST'))
def aboutUs():
  return render_template('about.html')